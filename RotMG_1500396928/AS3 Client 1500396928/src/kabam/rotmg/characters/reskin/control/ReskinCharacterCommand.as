package kabam.rotmg.characters.reskin.control
{
   import com.company.assembleegameclient.objects.Player;
   import com.company.assembleegameclient.parameters.Parameters;
   import kabam.lib.net.api.MessageProvider;
   import kabam.lib.net.impl.SocketServer;
   import kabam.rotmg.classes.model.CharacterSkin;
   import kabam.rotmg.core.StaticInjectorContext;
   import kabam.rotmg.game.model.GameModel;
   import kabam.rotmg.messaging.impl.GameServerConnection;
   import kabam.rotmg.messaging.impl.outgoing.Reskin;
   
   public class ReskinCharacterCommand
   {
       
      
      [Inject]
      public var skin:CharacterSkin;
      
      [Inject]
      public var messages:MessageProvider;
      
      [Inject]
      public var server:SocketServer;
      
      public function ReskinCharacterCommand()
      {
         super();
      }
      
      public function execute() : void
      {
         var _loc1_:Reskin = this.messages.require(GameServerConnection.RESKIN) as Reskin;
         _loc1_.skinID = this.skin.id;
         var _loc2_:Player = StaticInjectorContext.getInjector().getInstance(GameModel).player;
         if(_loc2_ != null)
         {
            _loc2_.clearTextureCache();
            if(Parameters.skinTypes16.indexOf(_loc1_.skinID) != -1)
            {
               _loc2_.size_ = 70;
            }
            else
            {
               _loc2_.size_ = 100;
            }
         }
         this.server.sendMessage(_loc1_);
      }
   }
}
