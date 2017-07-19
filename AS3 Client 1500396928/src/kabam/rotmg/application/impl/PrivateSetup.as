package kabam.rotmg.application.impl
{
   import com.company.assembleegameclient.parameters.Parameters;
   import kabam.rotmg.application.api.ApplicationSetup;
   
   public class PrivateSetup implements ApplicationSetup
   {
       
      
      private var SERVER:String;
      
      private var UNENCRYPTED:String;
      
      private var ENCRYPTED:String;
      
      private var ANALYTICS:String;
      
      private var BUILD_LABEL:String;
      
      public function PrivateSetup()
      {
         this.SERVER = "rotmgtesting.appspot.com";
         this.UNENCRYPTED = "http://" + this.SERVER;
         this.ENCRYPTED = "https://" + this.SERVER;
         this.ANALYTICS = "UA-99999999-1";
         this.BUILD_LABEL = "<font color=\'#FFEE00\'>TESTING APP ENGINE, PRIVATE SERVER</font> #{VERSION}";
         super();
      }
      
      public function getAppEngineUrl(param1:Boolean = false) : String
      {
         return !!param1?this.UNENCRYPTED:this.ENCRYPTED;
      }
      
      public function getAnalyticsCode() : String
      {
         return this.ANALYTICS;
      }
      
      public function getBuildLabel() : String
      {
         var _loc1_:String = Parameters.BUILD_VERSION + "." + Parameters.MINOR_VERSION;
         return this.BUILD_LABEL.replace("{VERSION}",_loc1_);
      }
      
      public function useLocalTextures() : Boolean
      {
         return true;
      }
      
      public function isToolingEnabled() : Boolean
      {
         return true;
      }
      
      public function isGameLoopMonitored() : Boolean
      {
         return true;
      }
      
      public function useProductionDialogs() : Boolean
      {
         return false;
      }
      
      public function areErrorsReported() : Boolean
      {
         return false;
      }
      
      public function areDeveloperHotkeysEnabled() : Boolean
      {
         return true;
      }
      
      public function isDebug() : Boolean
      {
         return true;
      }
   }
}
