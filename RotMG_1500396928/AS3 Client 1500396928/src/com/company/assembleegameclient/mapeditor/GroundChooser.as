package com.company.assembleegameclient.mapeditor
{
   import com.company.assembleegameclient.map.GroundLibrary;
   import com.company.assembleegameclient.objects.ObjectLibrary;
   import com.company.util.MoreStringUtil;
   import flash.utils.Dictionary;
   
   public class GroundChooser extends Chooser
   {
       
      
      private var cache:Dictionary;
      
      private var lastSearch:String = "";
      
      function GroundChooser(param1:String = "")
      {
         super(Layer.GROUND);
         this.cache = new Dictionary();
         this.reloadObjects(param1,"",true);
      }
      
      public function getLastSearch() : String
      {
         return this.lastSearch;
      }
      
      public function reloadObjects(param1:String, param2:String = "ALL", param3:Boolean = false) : void
      {
         var _loc5_:RegExp = null;
         var _loc7_:String = null;
         var _loc8_:XML = null;
         var _loc9_:int = 0;
         var _loc10_:GroundElement = null;
         if(!param3)
         {
            removeElements();
         }
         this.lastSearch = param1;
         var _loc4_:Vector.<String> = new Vector.<String>();
         if(param1 != "")
         {
            _loc5_ = new RegExp(param1,"gix");
         }
         var _loc6_:Dictionary = GroupDivider.GROUPS["Ground"];
         for each(_loc8_ in _loc6_)
         {
            _loc7_ = String(_loc8_.@id);
            if(!(param2 != "ALL" && !this.runFilter(_loc8_,param2)))
            {
               if(_loc5_ == null || _loc7_.search(_loc5_) >= 0)
               {
                  _loc4_.push(_loc7_);
               }
            }
         }
         _loc4_.sort(MoreStringUtil.cmp);
         for each(_loc7_ in _loc4_)
         {
            _loc9_ = GroundLibrary.idToType_[_loc7_];
            _loc8_ = GroundLibrary.xmlLibrary_[_loc9_];
            if(!this.cache[_loc9_])
            {
               _loc10_ = new GroundElement(_loc8_);
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
      
      private function runFilter(param1:XML, param2:String) : Boolean
      {
         var _loc3_:int = 0;
         switch(param2)
         {
            case ObjectLibrary.TILE_FILTER_LIST[1]:
               return !param1.hasOwnProperty("NoWalk");
            case ObjectLibrary.TILE_FILTER_LIST[2]:
               return param1.hasOwnProperty("NoWalk");
            case ObjectLibrary.TILE_FILTER_LIST[3]:
               return param1.hasOwnProperty("Speed") && Number(param1.elements("Speed")) < 1;
            case ObjectLibrary.TILE_FILTER_LIST[4]:
               return !param1.hasOwnProperty("Speed") || Number(param1.elements("Speed")) >= 1;
            default:
               return true;
         }
      }
   }
}
