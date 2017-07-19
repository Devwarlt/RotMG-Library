package com.company.assembleegameclient.mapeditor
{
   public class METile
   {
       
      
      public var types_:Vector.<int>;
      
      public var objName_:String = null;
      
      public var layerNumber:int;
      
      public function METile()
      {
         this.types_ = new <int>[-1,-1,-1];
         super();
         this.layerNumber = 0;
      }
      
      public function clone() : METile
      {
         var _loc1_:METile = new METile();
         _loc1_.types_ = this.types_.concat();
         _loc1_.objName_ = this.objName_;
         return _loc1_;
      }
      
      public function isEmpty() : Boolean
      {
         var _loc1_:int = 0;
         while(_loc1_ < Layer.NUM_LAYERS)
         {
            if(this.types_[_loc1_] != -1)
            {
               return false;
            }
            _loc1_++;
         }
         return true;
      }
   }
}
