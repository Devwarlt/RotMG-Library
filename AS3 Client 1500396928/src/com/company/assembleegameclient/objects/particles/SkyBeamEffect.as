package com.company.assembleegameclient.objects.particles
{
   import com.company.assembleegameclient.objects.GameObject;
   import com.company.assembleegameclient.util.FreeList;
   
   public class SkyBeamEffect extends ParticleEffect
   {
      
      private static const BUBBLE_PERIOD:int = 30;
       
      
      public var go_:GameObject;
      
      public var color_:uint;
      
      public var rise_:Number;
      
      public var radius:Number;
      
      public var height_:Number;
      
      public var maxRadius:Number;
      
      public var speed_:Number;
      
      public var lastUpdate_:int = -1;
      
      public function SkyBeamEffect(param1:GameObject, param2:EffectProperties)
      {
         super();
         this.go_ = param1;
         this.color_ = param2.color;
         this.rise_ = param2.rise;
         this.radius = param2.minRadius;
         this.maxRadius = param2.maxRadius;
         this.height_ = param2.zOffset;
         this.speed_ = param2.speed;
      }
      
      override public function update(param1:int, param2:int) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:SkyBeamParticle = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         if(this.go_.map_ == null)
         {
            return false;
         }
         if(this.lastUpdate_ < 0)
         {
            this.lastUpdate_ = Math.max(0,param1 - 400);
         }
         x_ = this.go_.x_;
         y_ = this.go_.y_;
         var _loc3_:int = int(this.lastUpdate_ / BUBBLE_PERIOD);
         while(_loc3_ < int(param1 / BUBBLE_PERIOD))
         {
            _loc4_ = _loc3_ * BUBBLE_PERIOD;
            _loc5_ = FreeList.newObject(SkyBeamParticle) as SkyBeamParticle;
            _loc5_.setColor(this.color_);
            _loc5_.height_ = this.height_;
            _loc5_.restart(_loc4_,param1);
            _loc6_ = 2 * Math.random() * Math.PI;
            _loc7_ = Math.random() * this.radius;
            _loc5_.setSpeed(this.speed_ + (this.maxRadius - _loc7_));
            _loc8_ = this.go_.x_ + _loc7_ * Math.cos(_loc6_);
            _loc9_ = this.go_.y_ + _loc7_ * Math.sin(_loc6_);
            map_.addObj(_loc5_,_loc8_,_loc9_);
            _loc3_++;
         }
         this.radius = Math.min(this.radius + this.rise_ * (param2 / 1000),this.maxRadius);
         this.lastUpdate_ = param1;
         return true;
      }
   }
}

import com.company.assembleegameclient.objects.particles.Particle;
import com.company.assembleegameclient.util.FreeList;

class SkyBeamParticle extends Particle
{
    
   
   public var startTime_:int;
   
   public var speed_:Number;
   
   public var height_:Number;
   
   function SkyBeamParticle()
   {
      var _loc1_:Number = Math.random();
      super(2542335,this.height_,80 + _loc1_ * 40);
   }
   
   public function setSpeed(param1:Number) : void
   {
      this.speed_ = param1;
   }
   
   public function restart(param1:int, param2:int) : void
   {
      this.startTime_ = param1;
      var _loc3_:Number = (param2 - this.startTime_) / 1000;
      z_ = this.height_ - this.speed_ * _loc3_;
   }
   
   override public function removeFromMap() : void
   {
      super.removeFromMap();
      FreeList.deleteObject(this);
   }
   
   override public function update(param1:int, param2:int) : Boolean
   {
      var _loc3_:Number = (param1 - this.startTime_) / 1000;
      z_ = this.height_ - this.speed_ * _loc3_;
      return z_ > 0;
   }
}
