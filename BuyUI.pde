class BuyUI {
  PImage sprite;
  ArrayList<PImage> towers;
  int selected = 0;
  String typeSelected = "dart00";
  String genericSelected = "dart";
  float x;
  float y;
  boolean inShop;
  boolean onMap = false;
  int y_quadrant;
  int x_quadrant;
  int quadrant_size = 150;
  boolean firstUpgrade = false;
  boolean secondUpgrade = false;
  boolean monkeySelected = false;
  Tower currentMonkey;
  
  BuyUI(float x, float y) {
    this.x = x;
    this.y = y;
    
  }
  
  void loadSprites(){
    towers = new ArrayList<>();
    towers.add(loadImage("sprites/towers/dart-big.png"));
    towers.add(loadImage("sprites/towers/ninja-big.png"));
    towers.add(loadImage("sprites/towers/tack-big.png"));
    towers.add(loadImage("sprites/towers/bomb-big.png"));
  }
  
  void display(){
    loadSprites();
    fill(99, 63, 36);
    rect(600, 0, 800, 660);
    
    fill(168, 143, 50);
    //println(selected);
    rect(610, quadrant_size*selected+10, quadrant_size-20, quadrant_size-20);
    
    
    tint(255, 255);
    int y = 0;
    for (PImage sprite : towers ) {
      pushMatrix();
      translate(x, y);
      scale(0.75, 0.75);
      image(sprite, 0, 0);
      popMatrix();
      y += 150;
    }
    
    if (onMap) {monkeyClicked();}
  }
  
  void tryFirstUpgrade(){
    if (currentMonkey.topPath < 4) {
      Upgrade info = getUpgradePrice(currentMonkey.towerGeneric, currentMonkey.topPath+1, 0);
      if (currentMonkey.topPath >= 2 && currentMonkey.crosspathed && currentMonkey.topPath != 3) {
        
      } else if (info.price > money) {
      }else {
        money -= info.price;
        playUpgradeSound();
        currentMonkey.topPath += 1;
        currentMonkey.towerUpgraded();
        if (currentMonkey.topPath >= 3) {
          currentMonkey.crosspathed = true;
        }
      }

    }
  }
  
  void trySecondUpgrade(){
    if (currentMonkey.botPath < 4) {
      Upgrade info = getUpgradePrice(currentMonkey.towerGeneric, currentMonkey.botPath+1, 0);
      if (currentMonkey.botPath >= 2 && currentMonkey.crosspathed && currentMonkey.botPath != 3) {
      } else if (info.price > money) {
      }else {
        money -= info.price;
        playUpgradeSound();
        currentMonkey.botPath += 1;
        currentMonkey.towerUpgraded();
        if (currentMonkey.botPath >= 3) {
          currentMonkey.crosspathed = true;
        }
      }
      
    }
  }
  

    
  void mouseReleased(){
    firstUpgrade = false;
    secondUpgrade = false;
    inShop = false;
    
    int x = mouseX;
    int y = mouseY;
    

    
    // Check x quadrant
    if (x > 600 && 600+quadrant_size > x) {
            // Y Quadrant One
      if (y > 0 && y < quadrant_size) {
        y_quadrant = 1;
      }
      else if (y > quadrant_size && y < quadrant_size * 2) {
        y_quadrant = 2;
      } else if (y > quadrant_size * 2 && y < quadrant_size * 3) {
        y_quadrant = 3;
      } else {
        y_quadrant = 4;
      }
      inShop = true;
    }
    
    // Clicking on a tower
    else if (TILE_SIZE*10 > x && TILE_SIZE*10 > y) {
      onMap = true;
      y_quadrant = floor(mouseY/TILE_SIZE);
      x_quadrant = floor(mouseX/TILE_SIZE);
      println("y: ", y_quadrant, " x: ",  x_quadrant);
    }
    
    else if (x > 600+quadrant_size && monkeySelected) {
      onMap = true;
      if (y > 280 && 280+150+20 > y) {
        tryFirstUpgrade();
      }
      if (y > 280+150+20 && 280+320 > y) {
        trySecondUpgrade();
      }
    } else {
      onMap = false;
    }
    
    
    action();
    
  }
  void action() {
    //println("asdasdsad");
    if (inShop) {
      selected = y_quadrant-1;
      monkeySelected = false;
    }
    switch (selected) {
      case 0: typeSelected = "dart00"; genericSelected = "dart"; break;
      case 1: typeSelected = "ninja00"; genericSelected = "ninja"; break;
      case 2: typeSelected = "tack00"; genericSelected = "tack"; break;
      case 3: typeSelected = "bomb00"; genericSelected = "bomb"; break;
    }
    
    
    
    //println(selected);
  }
  
  void monkeyClicked(){
    if (grid[y_quadrant][x_quadrant].tower != null) {
      monkeySelected = true;
      Tower monkey = grid[y_quadrant][x_quadrant].tower;
      currentMonkey = monkey;
      fill(133, 86, 40);
      rect(600+quadrant_size, 0, 1000-(600+quadrant_size), 660);
      
      // Draw the tower sprite
      pushMatrix();
      translate(750, 60);
      if (monkey.towerGeneric.equals("tack") || monkey.towerGeneric.equals("bomb")) {
        scale(3, 3);
      } else {
        scale(4, 4);
      }
      
      image(monkey.sprite, 0, 0);
      popMatrix();
      
      textSize(30);
      fill(255);
      text(monkey.getName(), 600+quadrant_size+10, 30);
      textSize(20);
      text(monkey.pops + " pops", 600+quadrant_size+10, 70);
      
      fill(99, 63, 36);
      rect(600+quadrant_size+20, 280, 210, 150);
      
      rect(600+quadrant_size+20, 280+150+20, 210, 150);
      PImage temp;
      temp = towerSprites.get(monkey.towerGeneric+(monkey.topPath+1)+"0");
      
      if (temp != null) {
        if ((monkey.crosspathed && monkey.topPath == 2)) {
          fill(200);
          text("Max Upgrade \nReached", 600+quadrant_size+80, 390);
        } else {
          pushMatrix();
          translate(600+quadrant_size+80, 280);
          if (monkey.towerGeneric == "tack") {
            scale (1.7, 1.7);
          } else {
            scale(2.5, 2.5);
          }
          
          image(temp, 0, 0);
          popMatrix();
          
          
          fill(220);
          Upgrade info = getUpgradePrice(monkey.towerGeneric, monkey.topPath+1, 0);
          textSize(30 - info.name.length());
          text(info.name, 600+quadrant_size+80, 390);
          text("$"+info.price, 600+quadrant_size+80, 420);
        }
        
      } else {
        fill(200);
          text("Max Upgrade \nReached", 600+quadrant_size+80, 390);
      }
      
      temp = towerSprites.get(monkey.towerGeneric+"0"+(monkey.botPath+1));
      if (temp != null) {
        if ((monkey.crosspathed && monkey.botPath == 2)) {
          fill(200);
          text("Max Upgrade \nReached", 600+quadrant_size+80, 390+170);
          
        } else {
          pushMatrix();
          translate(600+quadrant_size+80, 280+190);
          if (monkey.towerGeneric == "tack") {
            scale (1.7, 1.7);
          } else {
            scale(2.5, 2.5);
          }
          image(temp, 0, 0);
          popMatrix();
          
          fill(220);
          Upgrade info = getUpgradePrice(monkey.towerGeneric, 0, monkey.botPath+1);
          textSize(30 - info.name.length());
          text(info.name, 600+quadrant_size+80, 390+170);
          text("$"+info.price, 600+quadrant_size+80, 420+170);
        }
        
      } else {
        fill(200);
        text("Max Upgrade \nReached", 600+quadrant_size+80, 390+170);
      }
      
      // Draw the gray upgrade boxes
      fill(77, 65, 47);
      for (int i = 0; i < 4; i++) {
        rect(600+quadrant_size+30, 290+105-(35*i), 40, 30);
      }
      for (int i = 0; i < 4; i++) {
        rect(600+quadrant_size+30, 290+105-(35*i)+170, 40, 30);
      }
      
      fill(129, 245, 66);
      for (int i = 0; i < monkey.topPath; i++) {
        rect(600+quadrant_size+30, 290+105-(35*i), 40, 30);
      }
      for (int i = 0; i < monkey.botPath; i++) {
        rect(600+quadrant_size+30, 290+105-(35*i)+170, 40, 30);
      }
      
      
      
      
      
      
      //println(grid[y_quadrant][x_quadrant].tower);
    } else {
      monkeySelected = false;
    }
    
  }
    
    
    
  
  
  
  
  
}
