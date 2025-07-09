import processing.sound.*;

// CGRA151 Project Khonich 2024
// Bloons Monkey Tower Defense

import java.util.Arrays;


// Global variables
int GRID_SIZE = 10;
int TILE_SIZE = 60;
Tile[][] grid;
ArrayList<Bloon> bloons;
ArrayList<Tower> towers;
int lives = 500;
int money = 750;
int currentRound = 0;
ArrayList<String> rounds;
HashMap<String, Float> bloonSpeeds;
HashMap<Integer, String> tiers;
HashMap<String, PImage> bloonSprites;
HashMap<String, PImage> tileSprites;
HashMap<String, PImage> towerSprites;
HashMap<String, SoundFile> sounds;
ArrayList<String> ceramics;
ArrayList<Effect> effects;
ArrayList<Bloon> bloonsToAdd;
int bloonInterval = 30;
int speed = 1;
PImage fastForward;
PImage fastForwardPressed;
Boolean died = false;

Boolean gameStarted = false;
String difficulty = "easy";

BuyUI ui = new BuyUI(600, 0);
void setup() {
  surface.setTitle("Bloons Tower Defense: Processing");
  size(1000, 660);  // 600x600 for the grid, 60 extra pixels for UI
  PFont oetztype = createFont("OETZTYP_.TTF", 48);
  textFont(oetztype);

}

void setupGame(){
  money = 750;
  lives = 500;
  currentRound = 0;
  gameStarted = true;
  loadBloonSprites();
  loadTileSprites();
  loadGrid("grid_" + difficulty + ".txt");
  loadRounds("rounds.txt");
  loadBloonSpeeds("speed.txt");
  loadTowerSprites();
  loadSounds();
  ceramics = new ArrayList<>();
  ceramics.add("c0");
  ceramics.add("c1");
  ceramics.add("c2");
  ceramics.add("c3");
  ceramics.add("c4");
  ceramics.add("c5");
  ceramics.add("c6");
  ceramics.add("c7");
  ceramics.add("c8");
  ceramics.add("c9");
  bloonsToAdd = new ArrayList<>();
  fastForward = loadImage("sprites/gui/fast_foward.png");
  fastForwardPressed = loadImage("sprites/gui/fast_forward_pressed.png");
  
  
  
  
  getTierColor("speed.txt");
  bloons = new ArrayList<Bloon>();
  towers = new ArrayList<Tower>();
  effects = new ArrayList<Effect>();
  
  
  
  // Debug printing
  println("Loaded rounds:");
  for (String round : rounds) {
    println(round);
  }
  
  println("\nLoaded bloon speeds:");
  for (String key : bloonSpeeds.keySet()) {
    println(key + ": " + bloonSpeeds.get(key));
  }
  
  printGrid();
  
}

void drawGame() {
    background(255);
  
  
  if (grid != null) {
    displayGrid();
  } else {
    println("Error: Grid not initialized!");
  }
  if (bloons != null) {
    updateAndDisplayBloons();
  } else {
    println("Error: Bloons list not initialized!");
  }
  if (towers != null) {
    updateAndDisplayTowers();
  } else {
    println("Error: Towers list not initialized!");
  }
  displayUI();
  
  if (frameCount % bloonInterval == 0 && currentRound < rounds.size()) {  // Spawn new bloon every second
    spawnBloon();
  }
  ui.display();
  tickEffects();
  moveClones();
  
  frameRate(30*speed);
  
  pushMatrix();
  translate(500, 593);
  scale(2, 2);
  
  
  if (speed == 1) {
    image(fastForward, 0, 0);
  } else {
    image(fastForwardPressed, 0, 0);
  }
  popMatrix();
  fill(100);
  textSize(15);
  text("Quit", 20, 655);
  if (0 >= lives) {
    resetGame();
  }
}

void resetGame(){
  gameStarted = false;
  textSize(50);
  died = true;
}

void draw() {
  if (gameStarted) {
    drawGame();
  } else {
    background(100);
    text("Bloons Tower Defense", 100, 100);
    if (difficulty.equals("easy")) {
      fill(78, 168, 50);
    } else {
      fill(255);
    }
    text("Easy", 100, 200);
    if (difficulty.equals("medium")) {
      fill(232, 185, 56);
    } else {
      fill(255);
    }
    text("Medium", 100, 300);
    if (difficulty.equals("hard")) {
      fill(232, 62, 56);
    } else {
      fill(255);
    }
    text("Hard", 100, 400);
    fill(255);
    text("Play", 100, 500);
    if (died) {
      text("You died!", 450, 300);
      text("Round " + currentRound, 450, 360);
    }
  }
}

void moveClones() {
  for (Bloon bloon : bloonsToAdd) {
    bloons.add(bloon);
  }
  bloonsToAdd.clear();
}

void playCeramicSound(){
  SoundFile sound = sounds.get("ceramic");
  sound.play();
}

void playPopSound(){
  ArrayList<SoundFile> pops = new ArrayList<>();
  pops.add(sounds.get("pop1"));
  pops.add(sounds.get("pop2"));
  pops.add(sounds.get("pop3"));
  pops.add(sounds.get("pop4"));
  SoundFile sound = pops.get((int)random(pops.size()));
  sound.amp(0.0000000001);
  sound.play();
}

void playUpgradeSound(){
  SoundFile sound = sounds.get("upgrade");
  sound.play();
}

void loadSounds() {
  sounds = new HashMap<>();
  sounds.put("pop1", new SoundFile(this, "sounds/pop1.mp3"));
  sounds.put("pop2", new SoundFile(this, "sounds/pop2.mp3"));
  sounds.put("pop3", new SoundFile(this, "sounds/pop3.mp3"));
  sounds.put("pop4", new SoundFile(this, "sounds/pop4.mp3"));
  sounds.put("ceramic", new SoundFile(this, "sounds/ceramic.mp3"));
  sounds.put("lead", new SoundFile(this, "sounds/lead.mp3"));
  sounds.put("place", new SoundFile(this, "sounds/place.mp3"));
  sounds.put("upgrade", new SoundFile(this, "sounds/upgrade.mp3"));
}

void showRanges(){
  for (Tower tower: towers) {
    tower.showRange();
  }
}

void tickEffects(){
  for (int i = effects.size()-1; i >= 0; i--) {
    Effect effect = effects.get(i);
    effect.tick();
    effect.display();
    if (effect.expired) {
      effects.remove(i);
    }
  }
}


void getTierColor(String filename) {
  tiers = new HashMap<>();
  ArrayList<String> types = new ArrayList<>();
  
  String[] lines = loadStrings(filename);
  for (String line : lines) {
    String[] parts = line.split(":");
    if (parts.length == 2) {
      String type = parts[0].trim();
      float speed = Float.parseFloat(parts[1].trim());
      types.add(type);
    } else {
      println("Error: Invalid line in speed.txt: " + line);
    }
  }
  
  for (int i = 1; i < types.size()+1; i++) {
    tiers.put(i, types.get(i-1));
  }
  tiers.put(0, "re");
}

void loadGrid(String filename) {
  String[] lines = loadStrings(filename);
  grid = new Tile[GRID_SIZE][GRID_SIZE];
  for (int y = 0; y < GRID_SIZE; y++) {
    for (int x = 0; x < GRID_SIZE; x++) {
      char c = lines[y].charAt(x);
      grid[y][x] = new Tile(x, y, c == 'Q');
      if (c == 'S') {
        grid[y][x].isSpawn = true;
      } else if (c == 'E') {
        grid[y][x].isEnd = true;
      }
      grid[y][x].setTileSpriteByType();
    }
  }
}

void loadBloonSpeeds(String filename) {
  String[] lines = loadStrings(filename);
  bloonSpeeds = new HashMap<String, Float>();
  for (String line : lines) {
    String[] parts = line.split(":");
    if (parts.length == 2) {
      String type = parts[0].trim();
      float speed = Float.parseFloat(parts[1].trim());
      bloonSpeeds.put(type, speed);
    } else {
      println("Error: Invalid line in speed.txt: " + line);
    }
  }
}

void displayGrid() {
  for (int y = 0; y < GRID_SIZE; y++) {
    for (int x = 0; x < GRID_SIZE; x++) {
      grid[y][x].display();
    }
  }
}

void updateAndDisplayBloons() {
  for (int i = bloons.size() - 1; i >= 0; i--) {
    Bloon bloon = bloons.get(i);
    bloon.move();
    bloon.display();
    if (bloon.popped) {
      bloons.remove(i);
    }
  }
}

void updateAndDisplayTowers() {
  for (Tower tower : towers) {
    tower.display();
    tower.shoot(bloons);
  }
}

void displayUI() {
  fill(0);
  textSize(20);
  text("Lives: " + lives, 10, 630);
  text("Money: $" + money, 150, 630);
  text(" Round: " + (currentRound + 1), 300, 630);
}

void loadRounds(String filename) {
  String[] roundsArray = loadStrings(filename);
  rounds = new ArrayList<String>();
  for (String round : roundsArray) {
    rounds.add(round);
  }
}

void spawnBloon() {
  if (currentRound >= rounds.size()) {
    println("All rounds complete!");
    return;
  }

  String round = rounds.get(currentRound).trim();
  String[] bloonGroups = round.split(" ");
    bloonInterval = Integer.valueOf(bloonGroups[bloonGroups.length-1]);
  //bloonGroups = Arrays.copyOfRange(bloonGroups, 1, bloonGroups.length);
  if (bloonGroups.length > 1) {
    String group = bloonGroups[0];
    //println(group);
    //println(rounds);
    if (group.length() >= 3) {
      //System.out.println(group);
      //System.out.println(group.substring(0, group.length() - 2));
      int count = Integer.parseInt(group.substring(0, group.length() - 2));
      String type = group.substring(group.length() - 2);
      
      if (!type.equals("na")) {
        Float speed = bloonSpeeds.get(type);
        if (speed == null) {
          println("Error: No speed defined for bloon type " + type);
          return;
        }
        
        ArrayList<PVector> path = getPath();
        if (path.isEmpty()) {
          println("Error: No valid path for bloons! Skipping bloon spawn.");
          return;
        }
        
        bloons.add(new Bloon(type, speed, path));
      }
      

      
      // Update the round string
      if (count > 1) {
        bloonGroups[0] = (count - 1) + type;
      } else {
        bloonGroups = subset(bloonGroups, 1);
      }
      
      rounds.set(currentRound, join(bloonGroups, " "));
    } else {
      println("Error: Invalid bloon group format: " + group);
      currentRound++;
      money += 100; //Round cash reward
      //rounds.set(currentRound, join(subset(bloonGroups, 1), " "));
    }
  } else {
    money += 100;
    currentRound++;
  }
}



ArrayList<PVector> getPath() {
  ArrayList<PVector> path = new ArrayList<PVector>();
  PVector current = findSpawn();
  if (current == null) {
    println("Error: No spawn point found!");
    return path;
  }
  path.add(current);
  PVector previous = null;
  
  int safety = 0;
  int maxIterations = GRID_SIZE * GRID_SIZE;  // Maximum possible path length
  
  while (current != null && !isEndTile(current) && safety < maxIterations) {
    PVector next = findNextTile(current, previous);
    if (next == null) {
      println("Error: Path is incomplete! Stopped at: (" + current.x + ", " + current.y + ")");
      return path;
    }
    path.add(next);
    previous = current;
    current = next;
    safety++;
  }
  
  if (safety >= maxIterations) {
    println("Error: Path finding exceeded maximum iterations!");
    return new ArrayList<PVector>();  // Return empty path to avoid using an invalid path
  }
  
  if (current == null) {
    println("Error: Unexpected null tile in path!");
    return new ArrayList<PVector>();  // Return empty path to avoid using an invalid path
  }
  
  if (!isEndTile(current)) {
    println("Error: Path does not reach the end tile!");
    return new ArrayList<PVector>();  // Return empty path to avoid using an invalid path
  }
  
  //println("Path found successfully. Length: " + path.size());
  return path;
}

boolean isEndTile(PVector tile) {
  if (tile == null) return false;
  int x = int(tile.x);
  int y = int(tile.y);
  if (!isValidTile(x, y)) return false;
  return grid[y][x].isEnd;
}

PVector findSpawn() {
  for (int y = 0; y < GRID_SIZE; y++) {
    for (int x = 0; x < GRID_SIZE; x++) {
      if (grid[y][x].isSpawn) {
        return new PVector(x, y);
      }
    }
  }
  return null;
}

PVector findNextTile(PVector current, PVector previous) {
  if (current == null) {
    println("Error: Current tile is null in findNextTile!");
    return null;
  }
  
  int[][] directions = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}};
  for (int[] dir : directions) {
    int newX = int(current.x) + dir[0];
    int newY = int(current.y) + dir[1];
    if (isValidTile(newX, newY) && (previous == null || newX != int(previous.x) || newY != int(previous.y))) {
      Tile tile = grid[newY][newX];
      if (tile == null) {
        println("Error: Null tile found at (" + newX + ", " + newY + ")");
        continue;
      }
      if (tile.isPath || tile.isEnd) {
        return new PVector(newX, newY);
      }
    }
  }
  return null;
}

boolean isValidTile(int x, int y) {
  return x >= 0 && x < GRID_SIZE && y >= 0 && y < GRID_SIZE;
}

void playSparkles(int x, int y){
  for (int i = 0; i <= 0+(int)random(0); i++) {
    effects.add(new Effect("sparkle", x*TILE_SIZE + TILE_SIZE/2, y*TILE_SIZE + TILE_SIZE/2));
  }
  
}

void mousePressed() {
  if (gameStarted) {
    int x = mouseX / TILE_SIZE;
    int y = mouseY / TILE_SIZE;
    
    if (x < GRID_SIZE && y < GRID_SIZE && !grid[y][x].isPath && grid[y][x].tower == null && money >= 200) {
      //playSparkles(x, y);
      sounds.get("place").play();
      Tower tower = new Tower(x, y, ui.typeSelected, ui.genericSelected);
      towers.add(tower);
      grid[y][x].tower = tower;
      money -= tower.cost;
    }
    // 500, 593
    if (x * TILE_SIZE > 470 && 500+(39*2) > x * TILE_SIZE) {
      if (y * TILE_SIZE > 593) {
        if (speed == 1) {
          speed = 3;
        } else {
          speed = 1;
        }
      }
    }
    if (50 > mouseX) {
      if (mouseY > 650) {
        resetGame();
        died = false;
        
      }
    }
  } else {
    int x = mouseX;
    int y = mouseY;
    if (x > 100 && x < 300) {
      if (y > 160 && 260 > y) {
        difficulty = "easy";
      }
      if (y > 260 && 350 > y) {
        difficulty = "medium";
      }
      if (y > 350 && 440 > y) {
        difficulty = "hard";
      }
      if (y > 450 && 520 > y) {
        setupGame();
      }
    }
  }

}

Upgrade getUpgradePrice(String towerType, int topPath, int botPath) {
  switch (towerType) {
    case "tack": {
      switch (topPath) {
        case 1: return new Upgrade("Sharp Nails", "", 200);
        case 2: return new Upgrade("Longer Range", "", 350);
        case 3: return new Upgrade("Blade Shooter", "", 1250);
        case 4: return new Upgrade("Blade Maelstrom", "", 6500);
      }
      switch (botPath) {
        case 1: return new Upgrade("Faster Shooting", "", 200);
        case 2: return new Upgrade("More Tacks", "", 550);
        case 3: return new Upgrade("Tack Sprayer", "", 1250);
        case 4: return new Upgrade("Tack Zone", "", 7000);
      }
    }
    case "dart": {
      switch (topPath) {
        case 1: return new Upgrade("Sharper Darts", "", 100);
        case 2: return new Upgrade("Even Sharper Darts", "", 150);
        case 3: return new Upgrade("Spike-o-Pult", "", 400);
        case 4: return new Upgrade("Juggernaut", "", 1500);
      }
      switch (botPath) {
        case 1: return new Upgrade("Faster Shooting", "", 200);
        case 2: return new Upgrade("Even Faster Shooting", "", 150);
        case 3: return new Upgrade("Crossbow", "", 600);
        case 4: return new Upgrade("Crossbow Master", "", 3500);
      }
    }
    case "ninja": {
      switch (topPath) {
        case 1: return new Upgrade("Ninja Discipline", "", 150);
        case 2: return new Upgrade("Sharp Shurikens", "", 150);
        case 3: return new Upgrade("Double Shuriken", "", 750);
        case 4: return new Upgrade("Bloonjitsu", "", 2750);
      }
      switch (botPath) {
        case 1: return new Upgrade("Faster Shooting", "", 100);
        case 2: return new Upgrade("Even Faster Shooting", "", 150);
        case 3: return new Upgrade("Black Belt", "", 700);
        case 4: return new Upgrade("Ninja Master", "", 1750);
      }
    }
  }
  return new Upgrade("", "", 0);
}

void loadTowerSprites(){
  towerSprites = new HashMap<>();
  towerSprites.put("dart00", loadImage("sprites/towers/dart-monkey.png"));
  towerSprites.put("ninja00", loadImage("sprites/towers/ninja-monkey.png"));
  towerSprites.put("tack00", loadImage("sprites/towers/tack-shooter.png"));
  towerSprites.put("bomb00", loadImage("sprites/towers/bomb-tower.png"));
  
  towerSprites.put("dart01", loadImage("sprites/towers/dart/01.png"));
  towerSprites.put("dart11", loadImage("sprites/towers/dart/11.png"));
  towerSprites.put("dart10", loadImage("sprites/towers/dart/10.png"));
  towerSprites.put("dart20", loadImage("sprites/towers/dart/20.png"));
  towerSprites.put("dart02", loadImage("sprites/towers/dart/02.png"));
  towerSprites.put("dart22", loadImage("sprites/towers/dart/22.png"));
  towerSprites.put("dart03", loadImage("sprites/towers/dart/03.png"));
  towerSprites.put("dart04", loadImage("sprites/towers/dart/04.png"));
  towerSprites.put("dart30", loadImage("sprites/towers/dart/30.png"));
  towerSprites.put("dart40", loadImage("sprites/towers/dart/40.png"));
  towerSprites.put("dart21", loadImage("sprites/towers/dart/21.png"));
  
  // Dart place holders for 12, 31, 41, 13, 14, 32, 42, 23, 24;
  towerSprites.put("dart12", loadImage("sprites/towers/dart/11.png"));
  towerSprites.put("dart31", loadImage("sprites/towers/dart/30.png"));
  towerSprites.put("dart41", loadImage("sprites/towers/dart/40.png"));
  towerSprites.put("dart13", loadImage("sprites/towers/dart/03.png"));
  towerSprites.put("dart14", loadImage("sprites/towers/dart/04.png"));
  towerSprites.put("dart32", loadImage("sprites/towers/dart/30.png"));
  towerSprites.put("dart42", loadImage("sprites/towers/dart/40.png"));
  towerSprites.put("dart23", loadImage("sprites/towers/dart/03.png"));
  towerSprites.put("dart24", loadImage("sprites/towers/dart/04.png"));
  
  towerSprites.put("ninja04", loadImage("sprites/towers/ninja/04.png"));
  towerSprites.put("ninja03", loadImage("sprites/towers/ninja/03.png"));
  towerSprites.put("ninja02", loadImage("sprites/towers/ninja/02.png"));
  towerSprites.put("ninja01", loadImage("sprites/towers/ninja/01.png"));
  towerSprites.put("ninja40", loadImage("sprites/towers/ninja/40.png"));
  towerSprites.put("ninja30", loadImage("sprites/towers/ninja/30.png"));
  towerSprites.put("ninja20", loadImage("sprites/towers/ninja/20.png"));
  towerSprites.put("ninja10", loadImage("sprites/towers/ninja/10.png"));
  
  // Place holders for the cross paths
  // 41, 42, 31, 32, 22, 21, 12, 11
  // 14, 24, 13, 23, 12, 22, 11, 12
  towerSprites.put("ninja41", loadImage("sprites/towers/ninja/40.png"));
  towerSprites.put("ninja42", loadImage("sprites/towers/ninja/40.png"));
  towerSprites.put("ninja31", loadImage("sprites/towers/ninja/30.png"));
  towerSprites.put("ninja32", loadImage("sprites/towers/ninja/30.png"));
  
  // Crosspaths for 20s and 10s
  towerSprites.put("ninja22", loadImage("sprites/towers/ninja/20.png"));
  towerSprites.put("ninja21", loadImage("sprites/towers/ninja/20.png"));
  towerSprites.put("ninja12", loadImage("sprites/towers/ninja/10.png"));
  towerSprites.put("ninja11", loadImage("sprites/towers/ninja/10.png"));
  
  towerSprites.put("ninja14", loadImage("sprites/towers/ninja/04.png"));
  towerSprites.put("ninja24", loadImage("sprites/towers/ninja/04.png"));
  towerSprites.put("ninja13", loadImage("sprites/towers/ninja/03.png"));
  towerSprites.put("ninja23", loadImage("sprites/towers/ninja/03.png"));
  
  towerSprites.put("tack40", loadImage("sprites/towers/tack/40.png"));
  towerSprites.put("tack30", loadImage("sprites/towers/tack/30.png"));
  towerSprites.put("tack20", loadImage("sprites/towers/tack/00.png"));
  towerSprites.put("tack10", loadImage("sprites/towers/tack/00.png"));
  towerSprites.put("tack01", loadImage("sprites/towers/tack/00.png"));
  towerSprites.put("tack02", loadImage("sprites/towers/tack/02.png"));
  towerSprites.put("tack03", loadImage("sprites/towers/tack/03.png"));
  towerSprites.put("tack04", loadImage("sprites/towers/tack/04.png"));
  
  // Crosspaths
  // 41, 42, 31, 32, 22, 21, 11, 12
  // 14, 24, 13, 23, 12, 22
  towerSprites.put("tack24", loadImage("sprites/towers/tack/04.png"));
  towerSprites.put("tack14", loadImage("sprites/towers/tack/04.png"));
  towerSprites.put("tack41", loadImage("sprites/towers/tack/40.png"));
  towerSprites.put("tack42", loadImage("sprites/towers/tack/40.png"));
  towerSprites.put("tack13", loadImage("sprites/towers/tack/03.png"));
  towerSprites.put("tack23", loadImage("sprites/towers/tack/03.png"));
  towerSprites.put("tack31", loadImage("sprites/towers/tack/30.png"));
  towerSprites.put("tack32", loadImage("sprites/towers/tack/30.png"));
  towerSprites.put("tack21", loadImage("sprites/towers/tack/00.png"));
  towerSprites.put("tack22", loadImage("sprites/towers/tack/02.png"));
  towerSprites.put("tack12", loadImage("sprites/towers/tack/02.png"));
  towerSprites.put("tack11", loadImage("sprites/towers/tack/00.png"));
  towerSprites.put("tack10", loadImage("sprites/towers/tack/00.png"));
  towerSprites.put("tack01", loadImage("sprites/towers/tack/00.png"));
  
}

void loadBloonSprites(){
  bloonSprites = new HashMap<>();
  bloonSprites.put("re", loadImage("sprites/bloons/red.png"));
  bloonSprites.put("bu", loadImage("sprites/bloons/blue.png"));
  bloonSprites.put("gr", loadImage("sprites/bloons/green.png"));
  bloonSprites.put("ye", loadImage("sprites/bloons/yellow.png"));
  bloonSprites.put("pi", loadImage("sprites/bloons/pink.png"));
  bloonSprites.put("bl", loadImage("sprites/bloons/black.png"));
  bloonSprites.put("zb", loadImage("sprites/bloons/zebra.png"));
  bloonSprites.put("rb", loadImage("sprites/bloons/rainbow.png"));
  bloonSprites.put("c8", loadImage("sprites/bloons/ceramic5.png"));
  bloonSprites.put("c6", loadImage("sprites/bloons/ceramic4.png"));
  bloonSprites.put("c4", loadImage("sprites/bloons/ceramic3.png"));
  bloonSprites.put("c2", loadImage("sprites/bloons/ceramic2.png"));
  bloonSprites.put("c0", loadImage("sprites/bloons/ceramic1.png"));
  
  bloonSprites.put("c9", loadImage("sprites/bloons/ceramic5.png"));
  bloonSprites.put("c7", loadImage("sprites/bloons/ceramic4.png"));
  bloonSprites.put("c5", loadImage("sprites/bloons/ceramic3.png"));
  bloonSprites.put("c3", loadImage("sprites/bloons/ceramic2.png"));
  bloonSprites.put("c1", loadImage("sprites/bloons/ceramic1.png"));
}

void loadTileSprites(){
  tileSprites = new HashMap<>();
  tileSprites.put("grass", loadImage("sprites/tiles/grass4.png"));
  tileSprites.put("path", loadImage("sprites/tiles/cobblestone.png"));
}

void mouseReleased(){
  ui.mouseReleased();
}

void printGrid() {
  println("\nGrid layout:");
  for (int y = 0; y < GRID_SIZE; y++) {
    for (int x = 0; x < GRID_SIZE; x++) {
      if (grid[y][x].isPath) print("P");
      else if (grid[y][x].isSpawn) print("S");
      else if (grid[y][x].isEnd) print("E");
      else print("O");
    }
    println();
  }
}
