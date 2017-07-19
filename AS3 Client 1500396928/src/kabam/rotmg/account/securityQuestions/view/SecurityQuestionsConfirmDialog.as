package kabam.rotmg.account.securityQuestions.view
{
   import com.company.assembleegameclient.account.ui.Frame;
   import flash.filters.DropShadowFilter;
   import kabam.rotmg.text.model.TextKey;
   import kabam.rotmg.text.view.TextFieldDisplayConcrete;
   import kabam.rotmg.text.view.stringBuilder.LineBuilder;
   
   public class SecurityQuestionsConfirmDialog extends Frame
   {
       
      
      private var infoText:TextFieldDisplayConcrete;
      
      private var questionsList:Array;
      
      private var answerList:Array;
      
      public function SecurityQuestionsConfirmDialog(param1:Array, param2:Array)
      {
         this.questionsList = param1;
         this.answerList = param2;
         super(TextKey.SECURITY_QUESTIONS_CONFIRM_TITLE,TextKey.SECURITY_QUESTIONS_CONFIRM_LEFT_BUTTON,TextKey.SECURITY_QUESTIONS_CONFIRM_RIGHT_BUTTON);
         this.createAssets();
      }
      
      private function createAssets() : void
      {
         var _loc3_:String = null;
         var _loc1_:String = "";
         var _loc2_:int = 0;
         for each(_loc3_ in this.questionsList)
         {
            _loc1_ = _loc1_ + ("<font color=\"#7777EE\">" + LineBuilder.getLocalizedStringFromKey(_loc3_) + "</font>\n");
            _loc1_ = _loc1_ + (this.answerList[_loc2_] + "\n\n");
            _loc2_++;
         }
         _loc1_ = _loc1_ + LineBuilder.getLocalizedStringFromKey(TextKey.SECURITY_QUESTIONS_CONFIRM_TEXT);
         this.infoText = new TextFieldDisplayConcrete();
         this.infoText.setStringBuilder(new LineBuilder().setParams(_loc1_));
         this.infoText.setSize(12).setColor(11776947).setBold(true);
         this.infoText.setTextWidth(250);
         this.infoText.setMultiLine(true).setWordWrap(true).setHTML(true);
         this.infoText.filters = [new DropShadowFilter(0,0,0)];
         addChild(this.infoText);
         this.infoText.y = 40;
         this.infoText.x = 17;
         h_ = 280;
      }
      
      public function dispose() : void
      {
      }
      
      public function setInProgressMessage() : void
      {
         titleText_.setStringBuilder(new LineBuilder().setParams(TextKey.SECURITY_QUESTIONS_SAVING_IN_PROGRESS));
         titleText_.setColor(11776947);
      }
      
      public function setError(param1:String) : *
      {
         titleText_.setStringBuilder(new LineBuilder().setParams(param1));
         titleText_.setColor(16549442);
      }
   }
}
