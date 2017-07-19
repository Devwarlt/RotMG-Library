package kabam.rotmg.account.securityQuestions.view
{
   import com.company.assembleegameclient.account.ui.Frame;
   import com.company.assembleegameclient.account.ui.TextInputField;
   import kabam.rotmg.text.model.TextKey;
   import kabam.rotmg.text.view.stringBuilder.LineBuilder;
   
   public class SecurityQuestionsDialog extends Frame
   {
       
      
      private var errors:Array;
      
      private const minQuestionLength:int = 3;
      
      private const maxQuestionLength:int = 50;
      
      private const inputPattern:RegExp = /^[a-zA-Z0-9 ]+$/;
      
      private var fields:Array;
      
      private var questionsList:Array;
      
      public function SecurityQuestionsDialog(param1:Array, param2:Array)
      {
         this.errors = [];
         this.questionsList = param1;
         super(TextKey.SECURITY_QUESTIONS_DIALOG_TITLE,"",TextKey.SECURITY_QUESTIONS_DIALOG_SAVE);
         this.createAssets();
         if(param1.length == param2.length)
         {
            this.updateAnswers(param2);
         }
      }
      
      public function updateAnswers(param1:Array) : *
      {
         var _loc3_:TextInputField = null;
         var _loc2_:int = 1;
         for each(_loc3_ in this.fields)
         {
            _loc3_.inputText_.text = param1[_loc2_ - 1];
            _loc2_++;
         }
      }
      
      private function createAssets() : void
      {
         var _loc2_:String = null;
         var _loc3_:TextInputField = null;
         var _loc1_:int = 1;
         this.fields = [];
         for each(_loc2_ in this.questionsList)
         {
            _loc3_ = new TextInputField(_loc2_,false,240);
            addTextInputField(_loc3_);
            _loc3_.inputText_.tabEnabled = true;
            _loc3_.inputText_.tabIndex = _loc1_;
            _loc3_.inputText_.maxChars = this.maxQuestionLength;
            _loc1_++;
            this.fields.push(_loc3_);
         }
         rightButton_.tabIndex = _loc1_ + 1;
         rightButton_.tabEnabled = true;
      }
      
      public function clearErrors() : void
      {
         var _loc1_:TextInputField = null;
         titleText_.setStringBuilder(new LineBuilder().setParams(TextKey.SECURITY_QUESTIONS_DIALOG_TITLE));
         titleText_.setColor(11776947);
         this.errors = [];
         for each(_loc1_ in this.fields)
         {
            _loc1_.setErrorHighlight(false);
         }
      }
      
      public function areQuestionsValid() : Boolean
      {
         var _loc1_:TextInputField = null;
         for each(_loc1_ in this.fields)
         {
            if(_loc1_.inputText_.length < this.minQuestionLength)
            {
               this.errors.push(TextKey.SECURITY_QUESTIONS_TOO_SHORT);
               _loc1_.setErrorHighlight(true);
               return false;
            }
            if(_loc1_.inputText_.length > this.maxQuestionLength)
            {
               this.errors.push(TextKey.SECURITY_QUESTIONS_TOO_LONG);
               _loc1_.setErrorHighlight(true);
               return false;
            }
         }
         return true;
      }
      
      public function displayErrorText() : void
      {
         var _loc1_:String = this.errors.length == 1?this.errors[0]:TextKey.MULTIPLE_ERRORS_MESSAGE;
         this.setError(_loc1_);
      }
      
      public function dispose() : void
      {
         this.errors = null;
         this.fields = null;
         this.questionsList = null;
      }
      
      public function getAnswers() : Array
      {
         var _loc2_:TextInputField = null;
         var _loc1_:Array = [];
         for each(_loc2_ in this.fields)
         {
            _loc1_.push(_loc2_.inputText_.text);
         }
         return _loc1_;
      }
      
      override public function disable() : void
      {
         super.disable();
         titleText_.setStringBuilder(new LineBuilder().setParams(TextKey.SECURITY_QUESTIONS_SAVING_IN_PROGRESS));
      }
      
      public function setError(param1:String) : *
      {
         titleText_.setStringBuilder(new LineBuilder().setParams(param1,{"min":this.minQuestionLength}));
         titleText_.setColor(16549442);
      }
   }
}
