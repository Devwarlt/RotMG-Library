package com.company.assembleegameclient.mapeditor
{
   import com.company.assembleegameclient.objects.ObjectLibrary;
   import com.company.util.MoreStringUtil;
   import flash.utils.Dictionary;
   
   public class DungeonChooser extends Chooser
   {
       
      
      public var currentDungon:String = "";
      
      private var cache:Dictionary;
      
      private var lastSearch:String = "";
      
      public function DungeonChooser(param1:String = "")
      {
         super(Layer.OBJECT);
         this.cache = new Dictionary();
         this.reloadObjects(GroupDivider.DEFAULT_DUNGEON,param1,true);
      }
      
      public function getLastSearch() : String
      {
         return this.lastSearch;
      }
      
      public function reloadObjects(param1:String, param2:String, param3:Boolean = false) : void
      {
         var _loc5_:RegExp = null;
         var _loc7_:String = null;
         var _loc8_:XML = null;
         var _loc9_:int = 0;
         var _loc10_:ObjectElement = null;
         this.currentDungon = param1;
         if(!param3)
         {
            removeElements();
         }
         this.lastSearch = param2;
         var _loc4_:Vector.<String> = new Vector.<String>();
         if(param2 != "")
         {
            _loc5_ = new RegExp(param2,"gix");
         }
         var _loc6_:Dictionary = GroupDivider.getDungeonsXML(this.currentDungon);
         for each(_loc8_ in _loc6_)
         {
            _loc7_ = String(_loc8_.@id);
            if(_loc5_ == null || _loc7_.search(_loc5_) >= 0)
            {
               _loc4_.push(_loc7_);
            }
         }
         _loc4_.sort(MoreStringUtil.cmp);
         for each(_loc7_ in _loc4_)
         {
            _loc9_ = ObjectLibrary.idToType_[_loc7_];
            _loc8_ = _loc6_[_loc9_];
            if(!this.cache[_loc9_])
            {
               _loc10_ = new ObjectElement(_loc8_);
               this.cache[_loc9_] = _loc10_;
            }
            else
            {
               _loc10_ = this.cache[_loc9_];
            }
            addElement(_loc10_);
         }
         scrollBar_.setIndicatorSize(HEIGHT,elementSprite_.height,true);
      }
   }
}
