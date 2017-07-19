package kabam.rotmg.dialogs.model
{
   import com.company.assembleegameclient.parameters.Parameters;
   import org.osflash.signals.Signal;
   
   public class DialogsModel
   {
       
      
      private var popupPriority:Array;
      
      private var queue:Vector.<PopupQueueEntry>;
      
      public function DialogsModel()
      {
         this.popupPriority = [PopupNamesConfig.BEGINNERS_OFFER_POPUP,PopupNamesConfig.NEWS_POPUP,PopupNamesConfig.DAILY_LOGIN_POPUP,PopupNamesConfig.PACKAGES_OFFER_POPUP];
         this.queue = new Vector.<PopupQueueEntry>();
         super();
      }
      
      public function addPopupToStartupQueue(param1:String, param2:Signal, param3:int, param4:Object) : void
      {
         if(param3 == -1 || this.canDisplayPopupToday(param1))
         {
            this.queue.push(new PopupQueueEntry(param1,param2,param3,param4));
            this.sortQueue();
         }
      }
      
      private function sortQueue() : void
      {
         this.queue.sort(function(param1:PopupQueueEntry, param2:PopupQueueEntry):*
         {
            var _loc3_:int = getPopupPriorityByName(param1.name);
            var _loc4_:int = getPopupPriorityByName(param2.name);
            if(_loc3_ < _loc4_)
            {
               return -1;
            }
            return 1;
         });
      }
      
      public function flushStartupQueue() : PopupQueueEntry
      {
         if(this.queue.length == 0)
         {
            return null;
         }
         var _loc1_:PopupQueueEntry = this.queue.shift();
         Parameters.data_[_loc1_.name] = new Date().time;
         return _loc1_;
      }
      
      public function canDisplayPopupToday(param1:String) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(!Parameters.data_[param1])
         {
            return true;
         }
         _loc2_ = Math.floor(Number(Parameters.data_[param1]) / 86400000);
         _loc3_ = Math.floor(new Date().time / 86400000);
         return _loc3_ > _loc2_;
      }
      
      public function getPopupPriorityByName(param1:String) : int
      {
         var _loc2_:int = this.popupPriority.indexOf(param1);
         if(_loc2_ < 0)
         {
            _loc2_ = int.MAX_VALUE;
         }
         return _loc2_;
      }
   }
}
