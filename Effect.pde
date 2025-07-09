class Effect {
  String type;
  PImage sprite;
  double time;
  boolean expired;
  double max_length;
  float x;
  float y;
  
  Effect(String type, float x, float y) {
    this.type = type;
    this.time = 10;
    max_length = time;
    this.expired = false;
    getSprite();
    this.x = x;
    this.y = y;
  }
  
  void display(){
    
    if (sprite != null) {
      tint(255, Math.round(time/max_length*255));
      pushMatrix();
      translate(x, y);
      switch (type) {
        case "pop": scale(2.2, 2.2); break;
        case "sparkle": scale(1, 1); break;
      }
      
      image(sprite, 0-20, 0-20);
      popMatrix();
      tint(255, 255);
    }
  }
  
  void getSprite() {
    switch (type) {
      case "pop": sprite = loadImage("sprites/effects/pop.png"); break;
      case "sparkle": sprite = loadImage("sprites/effects/sparkle.png"); break;
    }
  }
  
  void tick(){
    time -= 1;
    if (0 > time) {
      expired = true;
    }
  }
  
  
}
