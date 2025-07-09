class Tile {
  int x, y;
  boolean isPath;
  boolean isSpawn;
  boolean isEnd;
  boolean isGrass;
  PImage sprite;
  float angle;
  Tower tower;
  
  Tile(int x, int y, boolean isPath) {
    this.x = x;
    this.y = y;
    this.isPath = isPath;
    this.isSpawn = false;
    this.isEnd = false;
    
    
  }
  
  void setTileSpriteByType(){
    if (isPath) {
      sprite = tileSprites.get("path");
    } else if (isSpawn) {
      sprite = tileSprites.get("path");
    } else if (isEnd) {
      sprite = tileSprites.get("path");
    } else {
      sprite = tileSprites.get("grass");
    }
  }
  
  void display() {
    if (isPath) {
      sprite = tileSprites.get("path");
      fill(210, 166, 121);
    } else if (isSpawn) {
      fill(0, 255, 0);
    } else if (isEnd) {
      fill(255, 0, 0);
    } else {
      fill(51, 204, 0);
    }
    noStroke();
    rect(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
    if (sprite != null) {
      if (isPath) {
        tint(255, 200);
        pushMatrix();
        translate(x*TILE_SIZE, y*TILE_SIZE);
        scale(0.5, 0.5);
        image(sprite, 0, 0);
        popMatrix();
        tint(255, 255);
      } else {
        image(sprite, x*TILE_SIZE, y*TILE_SIZE);
      }
      
      
    }
    if (tower != null) {
      tower.display();
    }
  }
}
