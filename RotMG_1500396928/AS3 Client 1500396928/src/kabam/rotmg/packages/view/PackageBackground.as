package kabam.rotmg.packages.view
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class PackageBackground extends Sprite
   {
      
      private static const Background:Class = PackageBackground_Background;
       
      
      private var asset:DisplayObject;
      
      public function PackageBackground()
      {
         this.asset = this.makeBackground();
         super();
      }
      
      private function makeBackground() : DisplayObject
      {
         var _loc1_:DisplayObject = new Background();
         addChild(_loc1_);
         return _loc1_;
      }
   }
}
