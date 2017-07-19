package kabam.rotmg.pets.view.dialogs
{
   import com.company.assembleegameclient.ui.dialogs.CloseDialogComponent;
   import com.company.assembleegameclient.ui.dialogs.Dialog;
   import com.company.assembleegameclient.ui.dialogs.DialogCloser;
   import flash.display.DisplayObjectContainer;
   import flash.text.TextFieldAutoSize;
   import kabam.rotmg.pets.view.components.FusionStrengthFactory;
   import kabam.rotmg.text.view.TextFieldDisplayConcrete;
   import kabam.rotmg.text.view.stringBuilder.LineBuilder;
   import org.osflash.signals.Signal;
   
   public class NewAbility extends PetDialog implements DialogCloser
   {
       
      
      public var ability:String;
      
      private const closeDialogComponent:CloseDialogComponent = new CloseDialogComponent();
      
      private const abilityBox:DisplayObjectContainer = FusionStrengthFactory.makeRoundedBox();
      
      private var ABILITY_BOX_WIDTH:Number;
      
      private var ABILITY_BOX_HEIGHT:Number;
      
      private var abilityText:TextFieldDisplayConcrete;
      
      public function NewAbility(param1:String)
      {
         this.ABILITY_BOX_WIDTH = this.abilityBox.width;
         this.ABILITY_BOX_HEIGHT = this.abilityBox.height;
         this.abilityText = new TextFieldDisplayConcrete();
         this.ability = param1;
         super("NewAbility.gratz","NewAbility.text","NewAbility.righteous",null,null);
         this.closeDialogComponent.add(this,Dialog.LEFT_BUTTON);
      }
      
      public function getAbility() : String
      {
         return this.ability;
      }
      
      override protected function makeUIAndAdd() : void
      {
         this.abilityText.setAutoSize(TextFieldAutoSize.CENTER).setVerticalAlign(TextFieldDisplayConcrete.MIDDLE).setColor(9632505).setSize(16).setBold(true).setStringBuilder(new LineBuilder().setParams(this.ability));
         this.abilityBox.addChild(this.abilityText);
         addChild(this.abilityBox);
         box_.addChild(this.abilityBox);
         uiWaiter.pushArgs(this.abilityText.textChanged);
      }
      
      override protected function drawAdditionalUI() : void
      {
         super.drawAdditionalUI();
         this.abilityText.x = this.ABILITY_BOX_WIDTH / 2;
         this.abilityText.y = this.ABILITY_BOX_HEIGHT / 2;
         this.abilityBox.x = (WIDTH - this.abilityBox.width) / 2;
         this.abilityBox.y = textText_.getBounds(box_).bottom + titleYPosition;
         leftButton.y = this.abilityBox.getBounds(box_).bottom + buttonSpace;
      }
      
      public function getCloseSignal() : Signal
      {
         return this.closeDialogComponent.getCloseSignal();
      }
   }
}
