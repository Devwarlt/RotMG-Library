package com.company.assembleegameclient.map
{
   import com.company.util.GraphicsUtil;
   import flash.display.GradientType;
   import flash.display.GraphicsGradientFill;
   import flash.display.GraphicsPath;
   import flash.display.IGraphicsData;
   import flash.display.Shape;
   
   public class GradientOverlay extends Shape
   {
       
      
      private var gradientFill_:GraphicsGradientFill;
      
      private const gradientPath_:GraphicsPath = GraphicsUtil.getRectPath(0,0,10,600);
      
      private var gradientGraphicsData_:Vector.<IGraphicsData>;
      
      public function GradientOverlay()
      {
         super();
         this.gradientFill_ = new GraphicsGradientFill(GradientType.LINEAR,[0,0],[0,1],[0,255],GraphicsUtil.getGradientMatrix(10,600));
         this.gradientGraphicsData_ = new <IGraphicsData>[this.gradientFill_,this.gradientPath_,GraphicsUtil.END_FILL];
         graphics.drawGraphicsData(this.gradientGraphicsData_);
         visible = false;
      }
   }
}
