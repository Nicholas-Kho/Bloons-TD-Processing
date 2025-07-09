class Projectile {
  float x;
  float y;
  float angle;
  String type;
  PImage sprite;
  double x_velocity;
  double y_velocity;
  double time;
  double pierce;
  double range = 30;
  int pops = 0;
  int maxTime;
  int damage;
  ArrayList<Bloon> bloonsHit = new ArrayList<>();
  
  Projectile(String type, float angle, float x, float y, double velocity, double pierce, int damage, int timeDuration) {
    this.type = type;
    this.angle = angle;
    this.x = x;
    this.y = y;
    this.pierce = pierce;
    this.damage = damage;
    setSprite();
    x_velocity = cos(angle) * velocity;
    y_velocity = sin(angle) * velocity;
    time = 1000;
    this.time = timeDuration;
  }
  
  void setSprite(){
    switch (type) {
      case "dart": sprite = loadImage("sprites/projectiles/dart.png"); break;
      case "shuriken": sprite = loadImage("sprites/projectiles/shuriken.png"); break;
      case "tack": sprite = loadImage("sprites/projectiles/tack.png"); range = 25; break;
      case "spike": sprite = loadImage("sprites/projectiles/spike.png"); range = 40; break;
      case "megaspike": sprite = loadImage("sprites/projectiles/megaspike.png"); range = 40; break;
      case "arrow": sprite = loadImage("sprites/projectiles/arrow.png"); break;
      case "blade": sprite = loadImage("sprites/projectiles/blade.png"); range = 25; break;
    }
  }
  
  void damage(){
    for (Bloon bloon : bloons) {
      if (0 >= pierce) {
        break;
      }
      if (!bloonsHit.contains(bloon)) {
        float d = dist(x, y, bloon.x, bloon.y);
          if (d <= range) {
            //println(bloonsHit);
            bloonsHit.add(bloon);
            pierce -= 1;
            pops += 1;
            bloon.takeDamage(damage);
          }
      }
    }
    if (0 >= pierce) {
      time = 0;
    }
    
  }
  
  void tick(){
    time -= 1;
    x += x_velocity;
    y += y_velocity;
  }
  
  void display(){
    tick();
    damage();
    pushMatrix();
    translate(x, y);
    
    switch (type) {
      case "dart": scale(2, 2); rotate(angle-30); break;
      case "shuriken": scale(0.4, 0.4); rotate(angle-30); break;
      case "tack" : scale(0.9, 0.9); rotate(angle-30-radians(180)); break;
      case "blade" : scale(0.9, 0.9); rotate(angle-30-radians(180)); break;
      case "spike": scale(2.5, 2.5); rotate(angle-30);break;
      case "megaspike": scale(2.3, 2.3); rotate(angle-30);break;
      case "arrow": rotate(angle-30); break;
    }
    
    imageMode(CENTER);
    image(sprite, 0, 0);
    popMatrix();
    imageMode(CORNER);
    
  }
  
}
