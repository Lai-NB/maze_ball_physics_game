final int MENU = 0;
final int GAME = 1;
final int HIGHSCORES = 2;
final int TUTORIAL = 3;

int gameState = MENU;

float menuButtonW = 300;
float menuButtonH = 70;

int startTime;
float finalTime;

String[] highScores;

float boardSize = 750;
float halfBoard = boardSize / 2;

float thetaX = 0;
float thetaY = 0;

float tiltSpeed = radians(1.5);
float maxTilt = radians(30);

//Ball property
PVector ballStartPos;
PVector ballPos;
PVector ballVel;
PVector ballAcc;

float ballRadius = 20;

//Physics
float g = 9.81 * 10;
float dt = 1.0 / 60.0;
float accelerationScale = 1;

float restitution = 0.5;
float friction = 0.01;

boolean wPressed = false;
boolean aPressed = false;
boolean sPressed = false;
boolean dPressed = false;

ArrayList<Wall> walls;
float wallThickness = 30;

ArrayList<Hole> holes;

PVector goalPos;
float goalRadius = 30;

boolean gameWon = false;

float buttonRestart_W = 220;
float buttonRestart_H = 60;
boolean hoveringButtonRestart = false;
float buttonMainMenu_W = 220;
float buttonMainMenu_H = 60;
boolean hoveringButtonMainMenu = false;

void setup()
{
  size(1000, 1000, P3D);
  surface.setLocation(450, 25);
  smooth(8);
  
  walls = new ArrayList<Wall>();
  
  walls.add(new Wall(0 + wallThickness / 2, -halfBoard - wallThickness / 2, boardSize + wallThickness, wallThickness));   //Top boundary
  walls.add(new Wall(0 + wallThickness / 2, halfBoard + wallThickness / 2, boardSize + wallThickness, wallThickness));    //Bottom boundary
  walls.add(new Wall(-halfBoard + wallThickness / 2, 0, wallThickness, boardSize));   //Left boundary
  walls.add(new Wall(halfBoard + wallThickness / 2, 0, wallThickness, boardSize));    //Right boundary
  
  // MAIN MAZE LAYOUT //  
  walls.add(new Wall(-120, -250, 310, 30));  // Top horizontal
  walls.add(new Wall(-260, -120, 30, 230));  // Upper left vertical
  walls.add(new Wall(-50, -70, 30, 220));    // Upper middle vertical
  walls.add(new Wall(130, -300, 30, 150));   // Upper right vertical
  walls.add(new Wall(170, -120, 260, 30));   // Upper right horizontal
  walls.add(new Wall(285, 45, 30, 300));     // Right vertical
  walls.add(new Wall(40, 110, 300, 30));     // Center horizontal
  walls.add(new Wall(80, -5, 30, 100));      // Center right vertical
  walls.add(new Wall(-210, 240, 270, 30));   // Lower left horizontal
  walls.add(new Wall(20, 285, 30, 180));     // Lower middle vertical
  walls.add(new Wall(230, 300, 200, 30));    // Bottom right horizontal
  walls.add(new Wall(-125, 25, 120, 30));    // Small center blocker
  
  holes = new ArrayList<Hole>();
  
  holes.add(new Hole(-280, -330, 28));  //Top left upper hole
  holes.add(new Hole(-140, -175, 28));  //Top left lower hole
  holes.add(new Hole(30, -300, 28));    //Top middle upper hole
  holes.add(new Hole(70, -190, 28));    //Top middle lower hole
  holes.add(new Hole(200, -230, 28));   //Top right upper hole
  holes.add(new Hole(335, -190, 28));   //Top right lower hole
  holes.add(new Hole(-185, -50, 28));   //Middle left upper hole
  holes.add(new Hole(-250, 85, 28));   //Middle left lower hole
  holes.add(new Hole(160, -50, 28));    //Middle right upper hole
  holes.add(new Hole(210, 40, 28));     //Middle right lower hole
  holes.add(new Hole(-70, 170, 28));    //Bottom left upper hole
  holes.add(new Hole(-40, 310, 28));    //Bottom left lower hole
  holes.add(new Hole(220, 240, 28));    //Bottom right upper hole
  holes.add(new Hole(70, 345, 28));     //Bottom right lower hole
  
  goalPos = new PVector(300, -300);
  
  ballStartPos = new PVector(-300, 320);
  ballPos = ballStartPos.copy();
  ballVel = new PVector(0, 0);
  ballAcc = new PVector(0, 0);
}

void draw()
{
  background(200);

  if (gameState == MENU)
  {
    drawMainMenu();
    return;
  } 
  if (gameState == HIGHSCORES)
  {
    drawHighScores();
    return;
  }
  if (gameState == TUTORIAL)
  {
    drawTutorial();
    return;
  }
  
  if (wPressed) thetaX += tiltSpeed;
  if (sPressed) thetaX -= tiltSpeed;
  if (aPressed) thetaY -= tiltSpeed;
  if (dPressed) thetaY += tiltSpeed;
  
  thetaX = constrain(thetaX, -maxTilt, maxTilt);
  thetaY = constrain(thetaY, -maxTilt, maxTilt);

  translate(width / 2, height / 2);
  
  rotateY(thetaY);
  rotateX(thetaX);
  
  drawBoard();
  
  for (Wall wall : walls)
  {
    wall.display();
  }
  for (Hole hole : holes)
  {
    hole.display();
  }
  drawGoal();
  
  if (!gameWon)
  {
    //Calculate ball acceleration from tilt
    ballAcc.x = accelerationScale * g * sin(thetaY);
    ballAcc.y = -accelerationScale * g * sin(thetaX);
    
    //Update velocity using acceleration
    ballVel.add(PVector.mult(ballAcc, dt));
    
    ballVel.mult(1.0 - friction);
    
    //Update position using velocity
    ballPos.add(PVector.mult(ballVel, dt));
  
    //Collisions
    for (Wall wall : walls)
    {
      checkWallCollision(wall);
    }
    for (Hole hole : holes)
    {
      checkHoleCollision(hole);
    }
    checkGoalCollision();
  }
  
  drawBall();
  
  drawUI();
}

void drawMainMenu()
{
  hint(DISABLE_DEPTH_TEST);
  camera();

  background(30, 40, 50);

  fill(244, 244, 249);
  textAlign(CENTER, CENTER);
  textSize(72);
  text("MAZE BALL", width / 2, 180);

  textSize(28);
  fill(184, 219, 217);
  text("Physics Puzzle Game", width / 2, 250);
  
  drawMenuButton(width / 2, 370, "START GAME");
  drawMenuButton(width / 2, 470, "TUTORIAL");
  drawMenuButton(width / 2, 570, "HIGH SCORES");
  drawMenuButton(width / 2, 670, "QUIT");

  hint(ENABLE_DEPTH_TEST);
}

void drawMenuButton(float centerX, float centerY, String label)
{
  float x = centerX - menuButtonW / 2;
  float y = centerY - menuButtonH / 2;

  boolean hovering =
    mouseX > x &&
    mouseX < x + menuButtonW &&
    mouseY > y &&
    mouseY < y + menuButtonH;

  if (hovering)
  {
    fill(184, 219, 217);
  }
  else
  {
    fill(88, 111, 124);
  }
  noStroke();
  rectMode(CORNER);
  rect(x, y, menuButtonW, menuButtonH, 20);

  fill(255);
  textSize(26);
  textAlign(CENTER, CENTER);
  text(label, centerX, centerY - 3);
}

void drawTutorial()
{
  hint(DISABLE_DEPTH_TEST);

  camera();
  background(30, 40, 50);
  
  fill(244, 244, 249);
  textAlign(CENTER, CENTER);
  textSize(64);
  text("TUTORIAL", width / 2, 120);

  fill(47, 69, 80);
  stroke(184, 219, 217);
  strokeWeight(3);
  rectMode(CENTER);
  rect(width / 2, height / 2, 700, 500, 25);

  fill(184, 219, 217);
  textSize(40);
  text("CONTROLS", width / 2, 280);

  fill(244, 244, 249);
  textSize(24);
  textAlign(LEFT, CENTER);
  text("W - Tilt Board Up", 225, 350);     text("Q - Increase Restitution by 0.05", 475, 350);
  text("S - Tilt Board Down", 225, 400);   text("E - Decrese Restitution by 0.05", 475, 400);
  text("A - Tilt Board Left", 225, 450);   text("Z - Increase Friction by 0.01", 475, 450);
  text("D - Tilt Board Right", 225, 500);  text("C - Decrease Friction by 0.01", 475, 500);

  fill(184, 219, 217);
  textSize(40);
  textAlign(CENTER, CENTER);
  text("OBJECTIVE", width / 2, 600);

  fill(244, 244, 249);
  textSize(22);
  text("Guide the ball through the maze\n" + "Avoid holes and reach the green goal!", width / 2, 670);

  drawMenuButton(width / 2, 820, "BACK");

  hint(ENABLE_DEPTH_TEST);
}

void drawHighScores()
{
  hint(DISABLE_DEPTH_TEST);
  camera();

  background(30, 40, 50);

  fill(244, 244, 249);
  textAlign(CENTER, CENTER);
  textSize(64);
  text("HIGH SCORES", width / 2, 150);

  textSize(28);
  fill(184, 219, 217);
  String[] scores = loadStrings("highscores.txt");
  
  if (scores != null)
  {
    for (int i = 0; i < min(scores.length, 5); i++)
    {
      float score = float(scores[i]);
  
      text((i + 1) + ". " + formatTime(score), width / 2, 320 + i * 60);
    }
  }
  else
  {
    text("No Scores Yet", width / 2, 320);
  }

  drawMenuButton(width / 2, 650, "BACK");

  hint(ENABLE_DEPTH_TEST);
}

void keyPressed()
{
  if (key == 'w' || key == 'W') wPressed = true;
  if (key == 'a' || key == 'A') aPressed = true;
  if (key == 's' || key == 'S') sPressed = true;
  if (key == 'd' || key == 'D') dPressed = true;
  
  if (key == 'q' || key == 'Q')
  {
    restitution += 0.05;
  }
  
  if (key == 'e' || key == 'E')
  {
    restitution -= 0.05;
  }

  if (key == 'z' || key == 'Z')
  {
    friction += 0.01;
  }

  if (key == 'c' || key == 'C')
  {
    friction -= 0.01;
  }
  
  restitution = constrain(restitution, 0, 1);
  friction = constrain(friction, 0, 1);
}

void keyReleased()
{
  if (key == 'w' || key == 'W') wPressed = false;
  if (key == 'a' || key == 'A') aPressed = false;
  if (key == 's' || key == 'S') sPressed = false;
  if (key == 'd' || key == 'D') dPressed = false;
}

void drawBoard()
{
  pushMatrix();

  fill(150, 200, 255);
  stroke(0);
  translate(0, 0, -50);
  box(boardSize, boardSize, 100);  //Value z = depth, like -50 with +- 50, so -100 - 0.
  
  popMatrix();
}

class Wall
{
  float x;
  float y;
  float w;
  float h;
  
  Wall(float x, float y, float w, float h)
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  void display()
  {
    pushMatrix();
  
    translate(x, y, 20);
    fill(70, 85, 95);
    stroke(0);
    box(w, h, 40);
  
    popMatrix();
  }
}

class Hole
{
  float x;
  float y;
  float radius;

  Hole(float x, float y, float radius)
  {
    this.x = x;
    this.y = y;
    this.radius = radius;
  }

  void display()
  {
    pushMatrix();

    translate(x, y, 1);
    fill(10, 10, 15);
    noStroke();
    ellipse(0, 0, radius * 2, radius * 2);

    popMatrix();
  }
}

void drawGoal()
{
  pushMatrix();

  translate(goalPos.x, goalPos.y, 2);

  fill(120, 255, 180);
  noStroke();

  ellipse(0, 0, goalRadius * 2, goalRadius * 2);

  popMatrix();
}

void drawBall()
{
  pushMatrix();
  translate(ballPos.x, ballPos.y, ballRadius);
  
  fill(255, 100, 100);
  noStroke();
  sphere(ballRadius);
  popMatrix();
}

void drawUI()
{
  hint(DISABLE_DEPTH_TEST);
  camera();
  
  fill(255, 220);
  rectMode(CORNER);
  rect(10, 10, 180, 100);
  
  fill(0);
  textSize(20);
  textAlign(LEFT);
  text("Restitution: " + nf(restitution, 1, 2), 20, 35);
  text("Friction: " + nf(friction, 1, 2), 20, 65);
  
  float currentTime = (millis() - startTime) / 1000.0;
  text("Time: " + formatTime(currentTime), 20, 95);
  
  if (gameWon)  //Game Won Menu
  {
    //Light gray at the game scene
    fill(0, 150);
    rectMode(CORNER);
    rect(0, 0, width, height);
    
    // Main panel
    float panelW = 450;
    float panelH = 450;
  
    float panelX = width / 2 - panelW / 2;
    float panelY = height / 2 - panelH / 2;
  
    fill(47, 69, 80);
    stroke(184, 219, 217);
    strokeWeight(3);
    rect(panelX, panelY, panelW, panelH, 25);
  
    // Title shadow
    textAlign(CENTER, CENTER);
    textSize(64);
    fill(88, 111, 124);
    text("YOU WIN!", width / 2 + 4, panelY + 80 + 4);
    // Main title
    fill(244, 244, 249);
    text("YOU WIN!", width / 2, panelY + 80);
  
    textSize(24);
    fill(184, 219, 217);
    text("Maze Completed!", width / 2, panelY + 140);
    
    textSize(28);
    fill(244, 244, 249);
    text("Time: " + formatTime(finalTime), width / 2, panelY + 185);
  
    drawRestartButton();
    drawMainMenuButton();
  }
  
  hint(ENABLE_DEPTH_TEST);
}

void drawRestartButton()
{
  float buttonRestart_X = width / 2 - buttonRestart_W / 2;
  float buttonRestart_Y = height / 2 - 300 / 2 + 210;
  
  hoveringButtonRestart =
    mouseX > buttonRestart_X &&
    mouseX < buttonRestart_X + buttonRestart_W &&
    mouseY > buttonRestart_Y &&
    mouseY < buttonRestart_Y + buttonRestart_H;

  if (hoveringButtonRestart)
  {
    fill(184, 219, 217);
  }
  else
  {
    fill(88, 111, 124);
  }
  noStroke();
  rect(buttonRestart_X, buttonRestart_Y, buttonRestart_W, buttonRestart_H, 15);

  fill(255);
  textSize(28);
  textAlign(CENTER, CENTER);
  text("RESTART", width / 2, buttonRestart_Y + buttonRestart_H / 2);
}

void drawMainMenuButton()
{
  float buttonX = width / 2 - buttonMainMenu_W / 2;
  float buttonY = height / 2 - 300 / 2 + 285;

  hoveringButtonMainMenu =
    mouseX > buttonX &&
    mouseX < buttonX + buttonMainMenu_W &&
    mouseY > buttonY &&
    mouseY < buttonY + buttonMainMenu_H;

  if (hoveringButtonMainMenu)
  {
    fill(184, 219, 217);
  }
  else
  {
    fill(88, 111, 124);
  }

  noStroke();
  rect(buttonX, buttonY, buttonMainMenu_W, buttonMainMenu_H, 15);

  fill(255);
  textSize(24);
  textAlign(CENTER, CENTER);
  text("MAIN MENU", width / 2, buttonY + buttonMainMenu_H / 2);
}

boolean isHoveringButton(float centerX, float centerY)
{
  float x = centerX - menuButtonW / 2;
  float y = centerY - menuButtonH / 2;

  return mouseX > x &&
         mouseX < x + menuButtonW &&
         mouseY > y &&
         mouseY < y + menuButtonH;
}

void mousePressed()
{
  //Main Menu buttons
  if (gameState == MENU)
  {
    // Start button
    if (isHoveringButton(width / 2, 370))
    {
      gameState = GAME;
      restartGame();
    }
    
    // Tutorial button
    if (isHoveringButton(width / 2, 470))
    {
      gameState = TUTORIAL;
    }
    
    // High scores button
    if (isHoveringButton(width / 2, 570))
    {
      gameState = HIGHSCORES;
    }
    
    // Quit button
    if (isHoveringButton(width / 2, 670))
    {
      exit();
    }
  
    return;
  }

  //High Scores Menu
  if (gameState == HIGHSCORES)
  {
    if (isHoveringButton(width / 2, 650))
    {
      gameState = MENU;
    }

    return;
  }
  
  if (gameState == TUTORIAL)
  {
    if (isHoveringButton(width / 2, 820))
    {
      gameState = MENU;
    }
  
    return;
  }
  
  //Game Won Menu
  if (gameWon)
  {
    if (hoveringButtonRestart)
    {
      restartGame();
    }
    
    if (hoveringButtonMainMenu)
    {
      gameState = MENU;
    
      restartGame();
    }
  }
}

void restartGame()
{
  gameWon = false;

  ballPos = ballStartPos.copy();
  ballVel.set(0, 0);

  thetaX = 0;
  thetaY = 0;
  
  startTime = millis();
}

void checkWallCollision(Wall wall)
{
  //Find closest point on wall to ball
  float closestX = constrain(ballPos.x, wall.x - wall.w / 2, wall.x + wall.w / 2);
  float closestY = constrain(ballPos.y, wall.y - wall.h / 2, wall.y + wall.h / 2);

  //Calculate the distance
  PVector difference = new PVector(ballPos.x - closestX, ballPos.y - closestY);
  float distance = difference.mag();

  //Collision check
  if (distance < ballRadius)
  {
    //Prevent divide by zero
    if (distance == 0)
    {
      distance = 0.01;
    }

    //Collision normalize
    PVector normal = difference.copy();
    normal.normalize();

    //Push ball outside wall
    float overlap = ballRadius - distance;
    ballPos.add(PVector.mult(normal, overlap));

    //Bounce velocity
    float bounce = restitution;
    
    float velocityAlongNormal = ballVel.dot(normal);  //Calculate dot product, the ball vel and the normalized differ

    if (velocityAlongNormal < 0)  //If negative then bounce
    {
      PVector impulse = PVector.mult(normal, -(1 + bounce) * velocityAlongNormal);
      ballVel.add(impulse);
      
      //Friction impulse
      PVector tangent = ballVel.copy();
      float normalComponent = tangent.dot(normal);
      tangent.sub(PVector.mult(normal, normalComponent));
      
      if (tangent.mag() > 0)
      {
        tangent.normalize();
        PVector frictionForce = PVector.mult(tangent, -friction);
        ballVel.add(frictionForce);
      }
    }
  }
}

void checkHoleCollision(Hole hole)
{
  PVector holePos = new PVector(hole.x, hole.y);
  float distance = PVector.dist(ballPos, holePos);

  if (distance < hole.radius)
  {
    restartGame();
  }
}

void checkGoalCollision()
{
  float distanceGoal = PVector.dist(ballPos, goalPos);

  if (distanceGoal < ballRadius)
  {
    gameWon = true;
    
    finalTime = (millis() - startTime) / 1000.0;
    saveHighScore(finalTime);
  }
}

void saveHighScore(float score)
{
  String[] scores = loadStrings("highscores.txt");

  if (scores == null)
  {
    scores = new String[0];
  }

  String[] newScores = new String[scores.length + 1];
  arrayCopy(scores, newScores);
  newScores[newScores.length - 1] = str(score);

  float[] numericScores = new float[newScores.length];
  for (int i = 0; i < newScores.length; i++)
  {
    numericScores[i] = float(newScores[i]);
  }

  numericScores = sort(numericScores);
  for (int i = 0; i < numericScores.length; i++)
  {
    newScores[i] = str(numericScores[i]);
  }
  
  saveStrings("highscores.txt", newScores);
}

String formatTime(float seconds)
{
  int minutes = floor(seconds / 60);
  int secs = floor(seconds % 60);

  return nf(minutes, 2) + ":" + nf(secs, 2);
}

//Colors References
//rgb(0, 0, 0) - Black
//rgb(47, 69, 80) - Dark gray
//rgb(88, 111, 124) - Light gray
//rgb(184, 219, 217) - Light blue gray
//rgb(244, 244, 249) - Ghost white
