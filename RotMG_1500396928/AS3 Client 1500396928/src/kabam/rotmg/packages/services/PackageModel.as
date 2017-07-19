package kabam.rotmg.packages.services
{
   import kabam.rotmg.packages.model.PackageInfo;
   import org.osflash.signals.Signal;
   
   public class PackageModel
   {
       
      
      public var numSpammed:int = 0;
      
      public var dataChanged:Signal;
      
      private var models:Object;
      
      private var initialized:Boolean;
      
      public function PackageModel()
      {
         this.dataChanged = new Signal();
         super();
      }
      
      public function getInitialized() : Boolean
      {
         return this.initialized;
      }
      
      public function getPackageById(param1:int) : PackageInfo
      {
         return this.models[param1];
      }
      
      public function hasPackage(param1:int) : Boolean
      {
         return param1 in this.models;
      }
      
      public function setPackages(param1:Array) : void
      {
         var _loc2_:PackageInfo = null;
         this.models = {};
         for each(_loc2_ in param1)
         {
            _loc2_.dataChanged.add(this.onDataChanged);
            this.models[_loc2_.packageID] = _loc2_;
         }
         this.initialized = true;
         this.dataChanged.dispatch();
      }
      
      private function onDataChanged() : void
      {
         this.dataChanged.dispatch();
      }
      
      public function canPurchasePackage(param1:int) : Boolean
      {
         var _loc2_:PackageInfo = this.models[param1];
         return _loc2_ && _loc2_.canPurchase();
      }
      
      public function getPriorityPackage() : PackageInfo
      {
         var _loc2_:PackageInfo = null;
         var _loc1_:PackageInfo = null;
         for each(_loc2_ in this.models)
         {
            if(_loc1_ == null || _loc2_.priority > _loc1_.priority)
            {
               _loc1_ = _loc2_;
            }
         }
         return _loc1_;
      }
      
      public function hasPackages() : Boolean
      {
         var _loc1_:Object = null;
         for each(_loc1_ in this.models)
         {
            return true;
         }
         return false;
      }
   }
}
