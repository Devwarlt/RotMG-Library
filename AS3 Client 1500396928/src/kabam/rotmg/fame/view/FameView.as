package kabam.rotmg.fame.view
{
   import com.company.assembleegameclient.map.GroundLibrary;
   import com.company.assembleegameclient.objects.ObjectLibrary;
   import com.company.assembleegameclient.screens.ScoreTextLine;
   import com.company.assembleegameclient.screens.ScoringBox;
   import com.company.assembleegameclient.screens.TitleMenuOption;
   import com.company.assembleegameclient.sound.SoundEffectLibrary;
   import com.company.assembleegameclient.util.FameUtil;
   import com.company.rotmg.graphics.FameIconBackgroundDesign;
   import com.company.rotmg.graphics.ScreenGraphic;
   import com.company.util.BitmapUtil;
   import com.gskinner.motion.GTween;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.Rectangle;
   import flash.text.TextFieldAutoSize;
   import kabam.rotmg.text.model.TextKey;
   import kabam.rotmg.text.view.TextFieldDisplayConcrete;
   import kabam.rotmg.text.view.stringBuilder.LineBuilder;
   import kabam.rotmg.ui.view.components.ScreenBase;
   import org.osflash.signals.Signal;
   import org.osflash.signals.natives.NativeMappedSignal;
   
   public class FameView extends Sprite
   {
       
      
      public var closed:Signal;
      
      private var infoContainer:DisplayObjectContainer;
      
      private var overlayContainer:Bitmap;
      
      private var title:TextFieldDisplayConcrete;
      
      private var date:TextFieldDisplayConcrete;
      
      private var scoringBox:ScoringBox;
      
      private var finalLine:ScoreTextLine;
      
      private var continueBtn:TitleMenuOption;
      
      private var isAnimation:Boolean;
      
      private var isFadeComplete:Boolean;
      
      private var isDataPopulated:Boolean;
      
      public function FameView()
      {
         super();
         addChild(new ScreenBase());
         addChild(this.infoContainer = new Sprite());
         addChild(this.overlayContainer = new Bitmap());
         this.continueBtn = new TitleMenuOption(TextKey.OPTIONS_CONTINUE_BUTTON,36,false);
         this.continueBtn.setAutoSize(TextFieldAutoSize.CENTER);
         this.continueBtn.setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
         this.closed = new NativeMappedSignal(this.continueBtn,MouseEvent.CLICK);
      }
      
      public function setIsAnimation(param1:Boolean) : void
      {
         this.isAnimation = param1;
      }
      
      public function setBackground(param1:BitmapData) : void
      {
         this.overlayContainer.bitmapData = param1;
         var _loc2_:GTween = new GTween(this.overlayContainer,2,{"alpha":0});
         _loc2_.onComplete = this.onFadeComplete;
         SoundEffectLibrary.play("death_screen");
      }
      
      public function clearBackground() : void
      {
         this.overlayContainer.bitmapData = null;
      }
      
      private function onFadeComplete(param1:GTween) : void
      {
         removeChild(this.overlayContainer);
         this.isFadeComplete = true;
         if(this.isDataPopulated)
         {
            this.makeContinueButton();
         }
      }
      
      public function setCharacterInfo(param1:String, param2:int, param3:int) : void
      {
         this.title = new TextFieldDisplayConcrete().setSize(38).setColor(13421772);
         this.title.setBold(true).setAutoSize(TextFieldAutoSize.CENTER);
         this.title.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
         var _loc4_:String = ObjectLibrary.typeToDisplayId_[param3];
         this.title.setStringBuilder(new LineBuilder().setParams(TextKey.CHARACTER_INFO,{
            "name":param1,
            "level":param2,
            "type":_loc4_
         }));
         this.title.x = stage.stageWidth / 2;
         this.title.y = 225;
         this.infoContainer.addChild(this.title);
      }
      
      public function setDeathInfo(param1:String, param2:String) : void
      {
         this.date = new TextFieldDisplayConcrete().setSize(24).setColor(13421772);
         this.date.setBold(true).setAutoSize(TextFieldAutoSize.CENTER);
         this.date.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
         var _loc3_:LineBuilder = new LineBuilder();
         if(param2)
         {
            _loc3_.setParams(TextKey.DEATH_INFO_LONG,{
               "date":param1,
               "killer":this.convertKillerString(param2)
            });
         }
         else
         {
            _loc3_.setParams(TextKey.DEATH_INFO_SHORT,{"date":param1});
         }
         this.date.setStringBuilder(_loc3_);
         this.date.x = stage.stageWidth / 2;
         this.date.y = 272;
         this.infoContainer.addChild(this.date);
      }
      
      private function convertKillerString(param1:String) : String
      {
         var _loc2_:Array = param1.split(".");
         var _loc3_:String = _loc2_[0];
         var _loc4_:String = _loc2_[1];
         if(_loc4_ == null)
         {
            _loc4_ = _loc3_;
            switch(_loc4_)
            {
               case "lava":
                  _loc4_ = "Lava";
                  break;
               case "lava blend":
                  _loc4_ = "Lava Blend";
                  break;
               case "liquid evil":
                  _loc4_ = "Liquid Evil";
                  break;
               case "evil water":
                  _loc4_ = "Evil Water";
                  break;
               case "puke water":
                  _loc4_ = "Puke Water";
                  break;
               case "hot lava":
                  _loc4_ = "Hot Lava";
                  break;
               case "pure evil":
                  _loc4_ = "Pure Evil";
                  break;
               case "lod red tile":
                  _loc4_ = "lod Red Tile";
                  break;
               case "lod purple tile":
                  _loc4_ = "lod Purple Tile";
                  break;
               case "lod blue tile":
                  _loc4_ = "lod Blue Tile";
                  break;
               case "lod green tile":
                  _loc4_ = "lod Green Tile";
                  break;
               case "lod cream tile":
                  _loc4_ = "lod Cream Tile";
            }
         }
         else
         {
            _loc4_ = _loc4_.substr(0,_loc4_.length - 1);
            _loc4_ = _loc4_.replace(/_/g," ");
            _loc4_ = _loc4_.replace(/APOS/g,"\'");
            _loc4_ = _loc4_.replace(/BANG/g,"!");
         }
         if(ObjectLibrary.getPropsFromId(_loc4_) != null)
         {
            _loc4_ = ObjectLibrary.getPropsFromId(_loc4_).displayId_;
         }
         else if(GroundLibrary.getPropsFromId(_loc4_) != null)
         {
            _loc4_ = GroundLibrary.getPropsFromId(_loc4_).displayId_;
         }
         return _loc4_;
      }
      
      public function setIcon(param1:BitmapData) : void
      {
         var _loc2_:Sprite = null;
         _loc2_ = new Sprite();
         var _loc3_:Sprite = new FameIconBackgroundDesign();
         _loc3_.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
         _loc2_.addChild(_loc3_);
         var _loc4_:Bitmap = new Bitmap(param1);
         _loc4_.x = _loc2_.width / 2 - _loc4_.width / 2;
         _loc4_.y = _loc2_.height / 2 - _loc4_.height / 2;
         _loc2_.addChild(_loc4_);
         _loc2_.y = 20;
         _loc2_.x = stage.stageWidth / 2 - _loc2_.width / 2;
         this.infoContainer.addChild(_loc2_);
      }
      
      public function setScore(param1:int, param2:XML) : void
      {
         this.scoringBox = new ScoringBox(new Rectangle(0,0,784,150),param2);
         this.scoringBox.x = 8;
         this.scoringBox.y = 316;
         addChild(this.scoringBox);
         this.infoContainer.addChild(this.scoringBox);
         var _loc3_:BitmapData = FameUtil.getFameIcon();
         _loc3_ = BitmapUtil.cropToBitmapData(_loc3_,6,6,_loc3_.width - 12,_loc3_.height - 12);
         this.finalLine = new ScoreTextLine(24,13421772,16762880,TextKey.FAMEVIEW_TOTAL_FAME_EARNED,null,0,param1,"","",new Bitmap(_loc3_));
         this.finalLine.x = 10;
         this.finalLine.y = 470;
         this.infoContainer.addChild(this.finalLine);
         this.isDataPopulated = true;
         if(!this.isAnimation || this.isFadeComplete)
         {
            this.makeContinueButton();
         }
      }
      
      private function makeContinueButton() : void
      {
         this.infoContainer.addChild(new ScreenGraphic());
         this.continueBtn.x = stage.stageWidth / 2;
         this.continueBtn.y = 550;
         this.infoContainer.addChild(this.continueBtn);
         if(this.isAnimation)
         {
            this.scoringBox.animateScore();
         }
         else
         {
            this.scoringBox.showScore();
         }
      }
   }
}
