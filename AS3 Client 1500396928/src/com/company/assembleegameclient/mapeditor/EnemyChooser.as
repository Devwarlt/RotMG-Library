package com.company.assembleegameclient.mapeditor
{
   import com.company.assembleegameclient.objects.ObjectLibrary;
   import com.company.util.MoreStringUtil;
   import flash.utils.Dictionary;
   
   public class EnemyChooser extends Chooser
   {
       
      
      private var cache:Dictionary;
      
      private var lastSearch:String = "";
      
      private var filterTypes:Dictionary;
      
      function EnemyChooser(param1:String = "")
      {
         this.filterTypes = new Dictionary(true);
         super(Layer.OBJECT);
         this.cache = new Dictionary();
         this.reloadObjects(param1,"",0,-1,true);
         this.filterTypes[ObjectLibrary.ENEMY_FILTER_LIST[0]] = "";
         this.filterTypes[ObjectLibrary.ENEMY_FILTER_LIST[1]] = "MaxHitPoints";
         this.filterTypes[ObjectLibrary.ENEMY_FILTER_LIST[2]] = ObjectLibrary.ENEMY_FILTER_LIST[2];
      }
      
      public function getLastSearch() : String
      {
         return this.lastSearch;
      }
      
      public function reloadObjects(param1:String, param2:String = "", param3:Number = 0, param4:Number = -1, param5:Boolean = false) : void
      {
         var _loc8_:XML = null;
         var _loc11_:RegExp = null;
         var _loc13_:String = null;
         var _loc14_:int = 0;
         var _loc15_:ObjectElement = null;
         if(!param5)
         {
            removeElements();
         }
         this.lastSearch = param1;
         var _loc6_:Boolean = true;
         var _loc7_:Boolean = true;
         var _loc9_:Number = -1;
         var _loc10_:Vector.<String> = new Vector.<String>();
         if(param1 != "")
         {
            _loc11_ = new RegExp(param1,"gix");
         }
         if(param2 != "")
         {
            param2 = this.filterTypes[param2];
         }
         var _loc12_:Dictionary = GroupDivider.GROUPS["Enemies"];
         for each(_loc8_ in _loc12_)
         {
            _loc13_ = String(_loc8_.@id);
            if(!(_loc11_ != null && _loc13_.search(_loc11_) < 0))
            {
               if(param2 != "")
               {
                  _loc9_ = !!_loc8_.hasOwnProperty(param2)?Number(Number(_loc8_.elements(param2))):Number(-1);
                  if(_loc9_ < 0)
                  {
                     continue;
                  }
                  _loc6_ = _loc9_ < param3?false:true;
                  _loc7_ = param4 > 0 && _loc9_ > param4?false:true;
               }
               if(_loc6_ && _loc7_)
               {
                  _loc10_.push(_loc13_);
               }
            }
         }
         _loc10_.sort(MoreStringUtil.cmp);
         for each(_loc13_ in _loc10_)
         {
            _loc14_ = ObjectLibrary.idToType_[_loc13_];
            if(!this.cache[_loc14_])
            {
               _loc15_ = new ObjectElement(ObjectLibrary.xmlLibrary_[_loc14_]);
               this.cache[_loc14_] = _loc15_;
            }
            else
            {
               _loc15_ = this.cache[_loc14_];
            }
            addElement(_loc15_);
         }
         scrollBar_.setIndicatorSize(HEIGHT,elementSprite_.height,true);
      }
   }
}
