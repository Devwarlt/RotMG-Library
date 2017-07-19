package com.company.assembleegameclient.mapeditor
{
   import com.company.assembleegameclient.account.ui.CheckBoxField;
   import com.company.assembleegameclient.account.ui.Frame;
   import com.company.assembleegameclient.account.ui.TextInputField;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import kabam.lib.json.JsonParser;
   import kabam.rotmg.account.core.Account;
   import kabam.rotmg.application.api.ApplicationSetup;
   import kabam.rotmg.core.StaticInjectorContext;
   import kabam.rotmg.editor.view.components.savedialog.TagsInputField;
   import kabam.rotmg.fortune.components.TimerCallback;
   import kabam.rotmg.text.model.TextKey;
   import org.osflash.signals.Signal;
   import ru.inspirit.net.MultipartURLLoader;
   
   public class SubmitMapForm extends Frame
   {
      
      public static var cancel:Signal;
       
      
      public var mapName:TextInputField;
      
      public var descr:TextInputField;
      
      public var tags:TagsInputField;
      
      public var mapjm:String;
      
      public var mapInfo:Object;
      
      public var account:Account;
      
      public var checkbox:CheckBoxField;
      
      public function SubmitMapForm(param1:String, param2:Object, param3:Account)
      {
         super("SubmitMapForm.Title",TextKey.FRAME_CANCEL,TextKey.WEB_CHANGE_PASSWORD_RIGHT,null,300);
         cancel = new Signal();
         this.account = param3;
         this.mapjm = param1;
         this.mapInfo = param2;
         this.mapName = new TextInputField("Map Name");
         addTextInputField(this.mapName);
         this.tags = new TagsInputField("",238,50,true);
         addComponent(this.tags,12);
         this.descr = new TextInputField("Description",false,238,100,20,256,true);
         addTextInputField(this.descr);
         addSpace(35);
         this.checkbox = new CheckBoxField("Overwrite",true,12);
         addCheckBox(this.checkbox);
         this.enableButtons();
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      public static function isInitialized() : Boolean
      {
         return cancel != null;
      }
      
      private function disableButtons() : void
      {
         rightButton_.removeEventListener(MouseEvent.CLICK,this.onSubmit);
         leftButton_.removeEventListener(MouseEvent.CLICK,this.onCancel);
      }
      
      private function enableButtons() : void
      {
         rightButton_.addEventListener(MouseEvent.CLICK,this.onSubmit);
         leftButton_.addEventListener(MouseEvent.CLICK,this.onCancel);
      }
      
      private function onSubmit(param1:MouseEvent) : void
      {
         this.disableButtons();
         this.mapName.clearError();
         var _loc2_:JsonParser = StaticInjectorContext.getInjector().getInstance(JsonParser);
         var _loc3_:Object = _loc2_.parse(this.mapjm);
         var _loc4_:int = _loc3_["width"];
         var _loc5_:int = _loc3_["height"];
         var _loc6_:MultipartURLLoader = new MultipartURLLoader();
         _loc6_.addVariable("guid",this.account.getUserId());
         _loc6_.addVariable("password",this.account.getPassword());
         _loc6_.addVariable("name",this.mapName.text());
         _loc6_.addVariable("description",this.descr.text());
         _loc6_.addVariable("width",_loc4_);
         _loc6_.addVariable("height",_loc5_);
         _loc6_.addVariable("mapjm",this.mapjm);
         _loc6_.addVariable("tags",this.tags.text());
         _loc6_.addVariable("totalObjects",this.mapInfo.numObjects);
         _loc6_.addVariable("totalTiles",this.mapInfo.numTiles);
         _loc6_.addFile(this.mapInfo.thumbnail,"foo.png","thumbnail");
         _loc6_.addVariable("overwrite",!!this.checkbox.isChecked()?"on":"off");
         var _loc7_:ApplicationSetup = StaticInjectorContext.getInjector().getInstance(ApplicationSetup);
         var _loc8_:* = _loc7_.getAppEngineUrl(true) + "/ugc/save";
         this.enableButtons();
         var _loc9_:Object = {
            "name":this.mapName.text(),
            "description":this.descr.text(),
            "width":_loc4_,
            "height":_loc5_,
            "mapjm":this.mapjm,
            "tags":this.tags.text(),
            "totalObjects":this.mapInfo.numObjects,
            "totalTiles":this.mapInfo.numTiles,
            "thumbnail":this.mapInfo.thumbnail,
            "overwrite":(!!this.checkbox.isChecked()?"on":"off")
         };
         if(this.validated(_loc9_))
         {
            _loc6_.addEventListener(Event.COMPLETE,this.onComplete);
            _loc6_.addEventListener(IOErrorEvent.IO_ERROR,this.onCompleteException);
            _loc6_.load(_loc8_);
         }
         else
         {
            this.enableButtons();
         }
      }
      
      private function onCompleteException(param1:IOErrorEvent) : void
      {
         this.descr.setError("Exception. If persists, please contact dev team.");
         this.enableButtons();
      }
      
      private function onComplete(param1:Event) : void
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc2_:MultipartURLLoader = MultipartURLLoader(param1.target);
         if(_loc2_.loader.data == "<Success/>")
         {
            this.descr.setError("Success! Thank you!");
            new TimerCallback(2,this.onCancel);
         }
         else
         {
            _loc3_ = _loc2_.loader.data.match("<.*>(.*)</.*>");
            _loc4_ = _loc3_.length > 1?_loc3_[1]:_loc2_.loader.data;
            this.descr.setError(_loc4_);
         }
         this.enableButtons();
      }
      
      private function onCancel(param1:MouseEvent = null) : void
      {
         cancel.dispatch();
         if(parent)
         {
            parent.removeChild(this);
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         if(rightButton_)
         {
            rightButton_.removeEventListener(MouseEvent.CLICK,this.onSubmit);
         }
         if(cancel)
         {
            cancel.removeAll();
            cancel = null;
         }
      }
      
      private function validated(param1:Object) : Boolean
      {
         if(param1["name"].length < 6 || param1["name"].length > 24)
         {
            this.mapName.setError("Map name length out of range (6-24 chars)");
            return false;
         }
         if(param1["description"].length < 10 || param1["description"].length > 250)
         {
            this.descr.setError("Description length out of range (10-250 chars)");
            return false;
         }
         return this.isValidMap();
      }
      
      private function isValidMap() : Boolean
      {
         if(this.mapInfo.numExits < 1)
         {
            this.descr.setError("Must have at least one User Dungeon End region drawn in this dungeon. (tmp)");
            return false;
         }
         if(this.mapInfo.numEntries < 1)
         {
            this.descr.setError("Must have at least one Spawn Region drawn in this dungeon. (tmp)");
            return false;
         }
         return true;
      }
   }
}
