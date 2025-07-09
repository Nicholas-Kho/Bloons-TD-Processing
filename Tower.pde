class Tower {
  int x, y;
  int cost = 200;
  int damage = 1;
  int range = 100;
  double cooldown = 0;
  double attack_cooldown = 250;
  PImage sprite;
  String type;
  String towerGeneric;
  int pops = 0;
  float angle;
  ArrayList<Projectile> projectiles = new ArrayList<>();
  int topPath = 0;
  int botPath = 0;
  Boolean crosspathed = false;
  
  Tower(int x, int y, String type, String genericType) {
    this.x = x;
    this.y = y;
    this.type = type;
    loadTowerSpriteByType();
    towerGeneric = genericType;
    angle = 30;
    
    
  }
  
    String getName(){
    switch (towerGeneric) {
      case "dart": return "Dart Monkey";
      case "ninja": return "Ninja Monkey";
      case "tack": return "Tack Shooter";
      case "bomb": return "Bomb Shooter";
      default: return "";
    }
  }

  void towerUpgraded(){
    cooldown = 0;
    range += 5 * topPath;
    range += 5 * botPath;
    type = (towerGeneric + String.valueOf(topPath) + String.valueOf(botPath));
    loadTowerSpriteByType();
  }
  
  void tickProjectiles(){
    // Tick all the projectiles
    for (int i = projectiles.size()-1; i >= 0; i--) {
      
      Projectile projectile = projectiles.get(i);
      
      //println(projectile);
      projectile.display(); // ALso ticks the projectiles
      if (0 >= projectile.time) {
        this.pops += projectile.pops;
        projectiles.remove(i);
      }
    }
  }
  
  void display() {
    setColor();
    
    tint(255, 255);
    pushMatrix();
    translate(x*TILE_SIZE+30, y*TILE_SIZE+30);
    
    if (towerGeneric != "tack") {
      rotate(angle-30);
    }
    if (towerGeneric == "tack" || towerGeneric == "bomb") {
      scale(1.0, 1.0);
    } else {
      scale(1.6, 1.6);
    }
    
    imageMode(CENTER);
    image(sprite, 0, 0);
    popMatrix();
    imageMode(CORNER);
    
    tickProjectiles();
  }
  
  void setColor() {
    if (cooldown > 0) {
      fill(100, 100, 100);
      
    } else {
      //fill(100, 100, 100);
      fill(0, 0, 255);
    }
  }
  
  void showRange(){
    //ellipse(x * TILE_SIZE, y * TILE_SIZE, bloon.x, bloon.y);
  }
  
  void loadTowerSpriteByType(){
    sprite = towerSprites.get(type);
  }
  

  
  void shoot(ArrayList<Bloon> bloons) {
    if (cooldown > 0) {
      cooldown -= 5;
    } else {
          for (Bloon bloon : bloons) {
          noFill();
          
          float d = dist(x * TILE_SIZE+TILE_SIZE/2, y * TILE_SIZE+TILE_SIZE/2, bloon.x, bloon.y);
          if (d <= range) {
            
            PVector bloonPos = bloon.getPos();
            angle = atan2(bloonPos.y - y*TILE_SIZE-TILE_SIZE/2, bloonPos.x - x*TILE_SIZE-TILE_SIZE/2);

            String projType;
            int projSpeed = 7;
            int projPierce = 1;
            int projDamage = 1;
            int projDuration = 0;
            int projCooldown;
            
            switch (towerGeneric) {
              case "dart":
                projCooldown = 250;
                projType = "dart";
                projPierce += 1;
                projDuration = 150;
                switch (topPath) {
                  case 0: break;
                  case 1: projPierce += 1; break;
                  case 2: projPierce += 1; break;
                  case 3: projType = "spike"; projPierce += 17; projDamage += 1; projSpeed = 5; projCooldown += 100; break;
                  case 4: projType = "megaspike"; projPierce += 40; projDamage += 4; projSpeed = 5; projCooldown += 75; break;
                }
                switch (botPath) {
                  case 0: break;
                  case 1: projCooldown -= 50; break;
                  case 2: projCooldown -= 100; break;
                  case 3: projCooldown -= 150; projPierce += 1; projDamage += 1; projType = "arrow"; break;
                  case 4: projCooldown = 8; projPierce += 1; projDamage += 1; projType = "arrow"; break;
                }
                projectiles.add(new Projectile(projType, angle, x*TILE_SIZE+TILE_SIZE/2, y*TILE_SIZE+TILE_SIZE/2, projSpeed, projPierce, projDamage, projDuration));
                //projectiles.add(new Projectile("dart", angle, x*TILE_SIZE+TILE_SIZE/2, y*TILE_SIZE+TILE_SIZE/2, 7, 2, damage, 100));
                cooldown += projCooldown;
                break;
              case "ninja":
                projCooldown = 150;
                projDamage = 1;
                projPierce = 2;
                projSpeed = 7;
                int times = 1;
                projDuration = 150;
                projType = "shuriken";
                switch (topPath) {
                  case 0: break;
                  case 1: projPierce += 1; break;
                  case 2: projPierce += 2; projCooldown -= 25; break;
                  case 3: times += 1; projPierce += 2; projCooldown -= 25; break;
                  case 4: times += 4; projPierce += 3; break;
                }
                switch (botPath) {
                  case 0: break;
                  case 1: projCooldown -=25; break;
                  case 2: projCooldown -=25; projDamage += 1; break;
                  case 3: projCooldown = 25; break;
                  case 4: projCooldown = 15; projPierce += 1; break;
                }
                
                if (times == 2) {
                  projectiles.add(new Projectile(projType, angle-radians(5), x*TILE_SIZE+TILE_SIZE/2, y*TILE_SIZE+TILE_SIZE/2, projSpeed, projPierce, projDamage, projDuration));
                  projectiles.add(new Projectile(projType, angle+radians(5), x*TILE_SIZE+TILE_SIZE/2, y*TILE_SIZE+TILE_SIZE/2, projSpeed, projPierce, projDamage, projDuration));
                } else if (times == 5) {
                  projectiles.add(new Projectile(projType, angle-radians(5), x*TILE_SIZE+TILE_SIZE/2, y*TILE_SIZE+TILE_SIZE/2, projSpeed, projPierce, projDamage, projDuration));
                  projectiles.add(new Projectile(projType, angle+radians(5), x*TILE_SIZE+TILE_SIZE/2, y*TILE_SIZE+TILE_SIZE/2, projSpeed, projPierce, projDamage, projDuration));
                  projectiles.add(new Projectile(projType, angle-radians(2), x*TILE_SIZE+TILE_SIZE/2, y*TILE_SIZE+TILE_SIZE/2, projSpeed, projPierce, projDamage, projDuration));
                  projectiles.add(new Projectile(projType, angle+radians(2), x*TILE_SIZE+TILE_SIZE/2, y*TILE_SIZE+TILE_SIZE/2, projSpeed, projPierce, projDamage, projDuration));
                  projectiles.add(new Projectile(projType, angle, x*TILE_SIZE+TILE_SIZE/2, y*TILE_SIZE+TILE_SIZE/2, projSpeed, projPierce, projDamage, projDuration));
                }
                else {
                  projectiles.add(new Projectile(projType, angle, x*TILE_SIZE+TILE_SIZE/2, y*TILE_SIZE+TILE_SIZE/2, projSpeed, projPierce, projDamage, projDuration));
                }
                cooldown += projCooldown;
                break;
              case "tack":
                projCooldown = 300;
                projDamage = 1;
                projPierce = 1;
                projSpeed = 7;
                projDuration = 15;
                projType = "tack";
                int projMultiplier = 1;
                switch (topPath) {
                  case 0: break;
                  case 1: projPierce += 1; break;
                  case 2: projPierce += 1; projDuration += 5; break;
                  case 3: projPierce += 3; projDamage += 1; projType = "blade"; projDuration += 10; break;
                  case 4: projPierce += 5; projDamage += 2; projType = "blade"; projCooldown = 50; break;
                }
                switch (botPath) {
                  case 0: break;
                  case 1: projCooldown -= 100; break;
                  case 2: projMultiplier = 2; break;
                  case 3: projMultiplier = 2; projCooldown = 150;  break;
                  case 4: projMultiplier = 4; projCooldown = 20; projDuration += 15;  break;
                }
                println(projMultiplier);
                if (projMultiplier == 1) {
                  for (int i = 0; i < 8; i++) {
                    projectiles.add(new Projectile(projType, radians(i*45), x*TILE_SIZE+TILE_SIZE/2, y*TILE_SIZE+TILE_SIZE/2, projSpeed, projPierce, projDamage, projDuration));
                  //projectiles.add(new Projectile("tack", radians(i*45), x*TILE_SIZE+TILE_SIZE/2, y*TILE_SIZE+TILE_SIZE/2, 7, 1, damage, 15));
                  }
                } else if (projMultiplier == 2) {
                  for (int i = 0; i < 16; i++) {
                    projectiles.add(new Projectile(projType, radians(i*45/2), x*TILE_SIZE+TILE_SIZE/2, y*TILE_SIZE+TILE_SIZE/2, projSpeed, projPierce, projDamage, projDuration));
                  }
                } else if (projMultiplier == 4) {
                  for (int i = 0; i < 32; i++) {
                    projectiles.add(new Projectile(projType, radians(i*45/4), x*TILE_SIZE+TILE_SIZE/2, y*TILE_SIZE+TILE_SIZE/2, projSpeed, projPierce, projDamage, projDuration));
                  }
                }
                cooldown += projCooldown;  
                
              
            }
            break;
            }
            
            
          } 
      }
      
    }
  
}
