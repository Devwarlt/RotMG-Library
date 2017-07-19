package com.company.assembleegameclient.mapeditor
{
   import com.company.assembleegameclient.objects.ObjectLibrary;
   import com.company.assembleegameclient.objects.animation.Animations;
   import com.company.assembleegameclient.objects.animation.AnimationsData;
   import com.company.assembleegameclient.ui.tooltip.ToolTip;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   
   public class ObjectElement extends Element
   {
       
      
      public var objXML_:XML;
      
      function ObjectElement(param1:XML)
      {
         var _loc3_:Animations = null;
         var _loc5_:Bitmap = null;
         var _loc7_:BitmapData = null;
         super(int(param1.@type));
         this.objXML_ = param1;
         var _loc2_:BitmapData = ObjectLibrary.getRedrawnTextureFromType(type_,100,true,false);
         var _loc4_:AnimationsData = ObjectLibrary.typeToAnimationsData_[int(param1.@type)];
         if(_loc4_ != null)
         {
            _loc3_ = new Animations(_loc4_);
            _loc7_ = _loc3_.getTexture(0.4);
            if(_loc7_ != null)
            {
               _loc2_ = _loc7_;
            }
         }
         _loc5_ = new Bitmap(_loc2_);
         var _loc6_:Number = (WIDTH - 4) / Math.max(_loc5_.width,_loc5_.height);
         _loc5_.scaleX = _loc5_.scaleY = _loc6_;
         _loc5_.x = WIDTH / 2 - _loc5_.width / 2;
         _loc5_.y = HEIGHT / 2 - _loc5_.height / 2;
         addChild(_loc5_);
      }
      
      override protected function getToolTip() : ToolTip
      {
         return new ObjectTypeToolTip(this.objXML_);
      }
      
      override public function get objectBitmap() : BitmapData
      {
         return ObjectLibrary.getRedrawnTextureFromType(type_,200,true,false);
      }
   }
}
