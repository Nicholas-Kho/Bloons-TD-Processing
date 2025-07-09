
class Bloon implements Cloneable{
  float x, y;
  String type;
  float speed;
  int health;
  int stunned = 0;
  boolean popped = false;
  ArrayList<PVector> path;
  int pathIndex = 0;
  int maxHealth;
  ArrayList<Effect> effects = new ArrayList<>();
  Boolean zebraCloned = false;
  Boolean blackCloned = false;
  Boolean pinkCloned = false;
  
  Bloon(String type, float speed, ArrayList<PVector> path) {
    this.type = type;
    this.speed = speed;
    this.path = path;
    x = path.get(0).x * TILE_SIZE + TILE_SIZE/2;
    y = path.get(0).y * TILE_SIZE + TILE_SIZE/2;
    setHealthByType();
    maxHealth = health;
  }
  
  
  void updateBloonParameters() {
    this.type = tiers.get(health);
    this.speed = bloonSpeeds.get(type);
  }
  
  void move() {
    if (stunned > 0) {
      stunned -=1;
    } else {
      if (pathIndex < path.size() - 1) {
      PVector target = path.get(pathIndex + 1);
      float targetX = target.x * TILE_SIZE + TILE_SIZE/2;
      float targetY = target.y * TILE_SIZE + TILE_SIZE/2;
      
      float angle = atan2(targetY - y, targetX - x);
      x += cos(angle) * speed;
      y += sin(angle) * speed;
      
      if (dist(x, y, targetX, targetY) < speed) {
        pathIndex++;
      }
    } else {
      reachEnd();
    }
    }
    
  }
  
  void display() {
    tint(255, 255);
    fill(getColorByType());
    PImage sprite = getSpriteByType(type);
    //ellipse(x, y, TILE_SIZE * 0.8, TILE_SIZE * 0.8);
    pushMatrix();
    translate(x, y);
    scale(1.1, 1.1);
    image(sprite, 0-sprite.width/2, 0-sprite.height/3-1);
    popMatrix();
    tickEffects();
  }
  
  void tickEffects(){
    for (int i = effects.size() - 1; i >= 0; i--) {
      Effect effect = effects.get(i);
      effect.tick();
      effect.display();
      if (effect.expired) {
        effects.remove(i);
      }
    }
  }
  
  color getColorByType() {
    switch(type) {
      case "bl": return color(0);
      case "pi": return color(255, 192, 203);
      case "ye": return color(255, 255, 0);
      case "gr": return color(0, 255, 0);
      case "bu": return color(0, 0, 255);
      case "re": return color(255, 0, 0);
      default: return color(150);
    }
  }
  
  PImage getSpriteByType(String type){
    //println(type);
    return bloonSprites.get(type);
  }
  
  PVector getPos() {
    return new PVector(x, y);
  }
  
  @Override
  protected Object clone() throws CloneNotSupportedException {
    return super.clone(); // Shallow clone
  }
  
  void checkClone(){
    if (health <= 8 && !zebraCloned && maxHealth > 8) {
      try {
        zebraCloned = true;
        Bloon cloned = (Bloon) this.clone();
        cloned.stunned += 10;
        cloned.updateBloonParameters();
        bloonsToAdd.add(cloned);
      } catch (CloneNotSupportedException e) {
        e.printStackTrace();
      }
      
    }
    if (health <= 7 && !blackCloned && maxHealth > 7) {
      try {
        blackCloned = true;
        Bloon cloned = (Bloon)this.clone();
        cloned.stunned += 12;
        cloned.updateBloonParameters();
        bloonsToAdd.add(cloned);
      } catch (CloneNotSupportedException e) {
        e.printStackTrace();
      }
    }
    
    if (health <= 6 && !pinkCloned && maxHealth > 6) {
      try {
        pinkCloned = true;
        Bloon cloned = (Bloon)this.clone();
        cloned.stunned += 13;
        cloned.updateBloonParameters();
        bloonsToAdd.add(cloned);
      } catch (CloneNotSupportedException e) {
        e.printStackTrace();
      }
    }
  }
  
  void takeDamage(int damage) {
    if (ceramics.contains(type)) {
      playCeramicSound();
    } else {
      money += 1;
      playPopSound();
      this.effects.add(new Effect("pop", x, y));
    }
    
     
    
    checkClone();
    //System.out.println("damaged " + type + " " + health);
    setHealthByType();
    health -= damage;
    checkClone();

    if (health <= 0) {
      popped = true;
      //money += 5;
    } else {
      updateBloonParameters();
      //System.out.println(tiers);
    }
      
  }
  
  void reachEnd() {
    lives -= health;
    popped = true;
  }
    void setHealthByType() {
    switch(type) {
      case "c9": health = 18; break;
      case "c8": health = 17; break;
      case "c7": health = 16; break;
      case "c6": health = 15; break;
      case "c5": health = 14; break;
      case "c4": health = 13; break;
      case "c3": health = 12; break;
      case "c2": health = 11; break;
      case "c1": health = 10; break;
      case "c0": health = 9; break;
      case "rb": health = 8; break;
      case "zb": health = 7; break;
      case "bl": health = 6; break;
      case "pi": health = 5; break;
      case "ye": health = 4; break;
      case "gr": health = 3; break;
      case "bu": health = 2; break;
      case "re": health = 1; break;
      default: health = 1;
    }
  }
}
