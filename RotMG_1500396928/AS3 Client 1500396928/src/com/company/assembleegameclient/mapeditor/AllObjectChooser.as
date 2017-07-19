package com.company.assembleegameclient.mapeditor
{
   import com.company.assembleegameclient.objects.ObjectLibrary;
   import com.company.util.MoreStringUtil;
   import flash.utils.Dictionary;
   
   public class AllObjectChooser extends Chooser
   {
       
      
      private var cache:Dictionary;
      
      private var lastSearch:String = "";
      
      function AllObjectChooser(param1:String = "", param2:String = "All Map Objects")
      {
         super(Layer.OBJECT);
         this.cache = new Dictionary();
         this.reloadObjects(param1,true,param2);
      }
      
      public function getLastSearch() : String
      {
         return this.lastSearch;
      }
      
      public function reloadObjects(param1:String = "", param2:Boolean = false, param3:String = "All Map Objects") : void
      {
         var _loc5_:RegExp = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:XML = null;
         var _loc10_:int = 0;
         var _loc11_:ObjectElement = null;
         if(!param2)
         {
            removeElements();
         }
         this.lastSearch = param1;
         var _loc4_:Vector.<String> = new Vector.<String>();
         if(param1 != "")
         {
            _loc5_ = new RegExp(param1,"gix");
         }
         var _loc6_:Dictionary = GroupDivider.GROUPS[param3];
         for each(_loc9_ in _loc6_)
         {
            _loc7_ = String(_loc9_.@id);
            _loc8_ = int(_loc9_.@type);
            if(_loc5_ == null || _loc7_.search(_loc5_) >= 0 || _loc8_ == int(param1))
            {
               _loc4_.push(_loc7_);
            }
         }
         _loc4_.sort(MoreStringUtil.cmp);
         for each(_loc7_ in _loc4_)
         {
            _loc10_ = ObjectLibrary.idToType_[_loc7_];
            _loc9_ = ObjectLibrary.xmlLibrary_[_loc10_];
            if(!this.cache[_loc10_])
            {
               _loc11_ = new ObjectElement(_loc9_);
               if(param3 == "All Game Objects")
               {
                  _loc11_.downloadOnly = true;
               }
               this.cache[_loc10_] = _loc11_;
            }
            else
            {
               _loc11_ = this.cache[_loc10_];
            }
            addElement(_loc11_);
         }
         scrollBar_.setIndicatorSize(HEIGHT,elementSprite_.height,true);
      }
   }
}
