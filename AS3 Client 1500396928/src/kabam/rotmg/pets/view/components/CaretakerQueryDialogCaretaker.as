package kabam.rotmg.pets.view.components
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import kabam.rotmg.pets.view.dialogs.CaretakerQueryDialog;
   
   public class CaretakerQueryDialogCaretaker extends Sprite
   {
       
      
      private var speechBubble:CaretakerQuerySpeechBubble;
      
      private var detailBubble:CaretakerQueryDetailBubble;
      
      private var icon:Bitmap;
      
      public function CaretakerQueryDialogCaretaker()
      {
         this.speechBubble = this.makeSpeechBubble();
         this.detailBubble = this.makeDetailBubble();
         this.icon = this.makeCaretakerIcon();
         super();
      }
      
      private function makeSpeechBubble() : CaretakerQuerySpeechBubble
      {
         var _loc1_:CaretakerQuerySpeechBubble = null;
         _loc1_ = new CaretakerQuerySpeechBubble(CaretakerQueryDialog.QUERY);
         _loc1_.x = 60;
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makeDetailBubble() : CaretakerQueryDetailBubble
      {
         var _loc1_:CaretakerQueryDetailBubble = null;
         _loc1_ = new CaretakerQueryDetailBubble();
         _loc1_.y = 60;
         return _loc1_;
      }
      
      private function makeCaretakerIcon() : Bitmap
      {
         var _loc1_:Bitmap = new Bitmap(this.makeDebugBitmapData());
         _loc1_.x = -16;
         _loc1_.y = -32;
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function makeDebugBitmapData() : BitmapData
      {
         return new BitmapDataSpy(42,42,true,4278255360);
      }
      
      public function showDetail(param1:String) : void
      {
         this.detailBubble.setText(param1);
         removeChild(this.speechBubble);
         addChild(this.detailBubble);
      }
      
      public function showSpeech() : void
      {
         removeChild(this.detailBubble);
         addChild(this.speechBubble);
      }
      
      public function setCaretakerIcon(param1:BitmapData) : void
      {
         this.icon.bitmapData = param1;
      }
   }
}
