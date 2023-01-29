GameController gameController;
int elapsedTimeGeneral = 0;
int elapsedTimeStart = 0;
boolean haveClicked = false;

Enemy testEnemy;
PImage testTexture;

//for enemy timer.
float timer = 1.5;
float prevTime = 0;
boolean timerToggle = false;

int a = 0;

float camZ;
float camY;
float camX = 0;
float camSpeed = 10;
PVector camVector;
PVector forwardVector;
int scale;

float rotation = 90;
float orbitRadius= 800;

color outlineColorPlanes;

PShape[] sidePlanes;
PImage sidePlaneTexture;

PShape topPlane;
PImage topPlaneTexture;

void setup()
{
  fullScreen(P3D);
  frameRate(60);
  background(0);
  //noStroke();

  //sidePlane1 = myRects();
  topPlane = myRects();
  spawnSidePlanes();

  sidePlaneTexture = loadImage("top3.jpeg");
  topPlaneTexture = loadImage("top4.jpeg");

  outlineColorPlanes = color(150, 0, 24);

  gameController = new GameController();
  gameController.gameSettings();
  camZ = gameController.camZ;
  camY = -height/1.5;
  scale = gameController.gameScale;
  camVector = new PVector(camX, camY, camZ);
}

void spawnSidePlanes()
{
  sidePlanes = new PShape[4];

  for (int a = 0; a < sidePlanes.length; a++)
  {
    sidePlanes[a] = myRects();
  }
}

void setSidePlaneTextures()
{
  for (int a = 0; a < sidePlanes.length; a++)
  {
    sidePlanes[a].setTexture(sidePlaneTexture);
  }
}

PShape myRects()
{
  PShape a = createShape(RECT, 0, 0, 170, 170);
  return a;
}

PVector calculateForwardVector()
{
  PVector vect = new PVector(camX, camY, camZ);
  return vect.normalize();
}

void draw()
{
  background(0);

  camVector.x = cos(radians(rotation)) * orbitRadius;
  camVector.z = sin(radians(rotation)) * orbitRadius;

  //camera(camX, camY, camZ, 0, 0, 0, 0, 1, 0);
  camera(camVector.x, camVector.y, camVector.z, 0, 0, 0, 0, 1, 0);

  updateGeneralTime();
  gameController.gameEndCheck();

  if (!gameController.gameEnded())
  {
    //game start.

    if (gameController.gameState == GameState.GAMEBEGIN)
    {
      //game begins.

      if (keyPressed)
      {
        if (keyCode == LEFT)
        {
          rotation++;
        } else if (keyCode == RIGHT)
        {
          rotation--;
        }

        if (keyCode == UP)
        {
          camVector.sub(calculateForwardVector().mult(camSpeed));
        } else if (keyCode == DOWN)
        {
          camVector.add(calculateForwardVector().mult(camSpeed));
        }
      }

      updateGameTime();

      if (gameController.gameTime - prevTime >= timer)
      {
        prevTime = gameController.gameTime;
        timerToggle = true;
      }

      if (timerToggle)
      {
        gameController.activateEnemies();
        timerToggle = false;
      }

      checkCollision();

      pushMatrix();
      scale(scale);
      gameController.renderEnemies();
      popMatrix();
    }

    pushMatrix();
    scale(scale);
    planes();
    popMatrix();
    gameController.renderGameUI();
  } else
  {
    //game ended
    background(0);
    if (gameController.gameState == GameState.GAMEEND_WIN)
    {
      //player won.
      gameController.renderEndUI(true);
    } else
    {
      //player lost.
      gameController.renderEndUI(false);
    }
  }
}

void planes()
{
  noStroke();
  fill(0);
  box(2);

  //stroke(outlineColorPlanes);
  fill(255, 186, 210);

  pushMatrix();
  //rectMode(CENTER);
  translate(-85, 0, 85);
  rotateX(radians(-90));
  //rect(0, 0, 170, 170);
  topPlane.setTexture(topPlaneTexture);
  shape(topPlane);
  popMatrix();

  fill(186, 219, 255);


  //rectMode(CENTER);
  /*for (int i = 0; i < sidePlanes.length; i++)
  {
    pushMatrix();
    translate(-85, 0, 85);
    setSidePlaneTextures();
    shape(sidePlanes[i]);
    //rotateX(radians(-90));
    //rect(0, 0, 170, 170);
    //sidePlane1.setTexture(sidePlaneTexture);
    //shape(sidePlane1);
    popMatrix();
  }*/
  
  setSidePlaneTextures();
  
  pushMatrix();
  //1
  translate(-85, 0, 85);
  shape(sidePlanes[0]);
  popMatrix();
  
  pushMatrix();
  //2
  translate(-85, 0, -85);
  shape(sidePlanes[1]);
  popMatrix();
  
  pushMatrix();
  //3
  translate(-85, 0, 85);
  rotateY(radians(90));
  shape(sidePlanes[2]);
  popMatrix();
  
  pushMatrix();
  //4
  translate(85, 0, 85);
  rotateY(radians(90));
  shape(sidePlanes[3]);
  popMatrix();
}

void keyPressed()
{
  if (!haveClicked)
  {
    haveClicked = true;
    elapsedTimeStart = elapsedTimeGeneral;
    gameController.setGameState(GameState.GAMEBEGIN);
  } else
  {
    //player already initiated the game start.
    //rotation stuff?
    if (gameController.gameState == GameState.GAMEBEGIN)
    {
    }
  }
}

void mousePressed()
{
  if (gameController.gameState == GameState.GAMEBEGIN)
  {
    if (mouseButton == LEFT)
    {
      ArrayList<Enemy> hitEnemies = new ArrayList<Enemy>();

      for (int a = 0; a < gameController.enemies.length; a++)
      {
        Enemy enemy = gameController.enemies[a];

        if (enemy.hit && !enemy.isDead)
        {
          hitEnemies.add(enemy);
        }
      }

      if (hitEnemies.size() > 0) //at least one hit.
      {
        if (hitEnemies.size() > 1)
        {
          //find the closest one to cam.
          float[] distances = new float[hitEnemies.size()];

          for (int i = 0; i < hitEnemies.size(); i++)
          {
            Enemy enemy = hitEnemies.get(i);
            PVector enemyCenter = new PVector(enemy.centerX * scale, enemy.centerY * scale, enemy.centerZ * scale);
            float dist = PVector.dist(camVector, enemyCenter);
            distances[i] = dist;
          }

          int minIndex = 0;
          for (int b = 0; b < distances.length; b++)
          {
            if (distances[minIndex] > distances[b])
              minIndex = b;
          }

          gameController.removeEnemy(hitEnemies.get(minIndex));
        } else
        {
          gameController.removeEnemy(hitEnemies.get(0));
        }
      } else //no hits.
      {
        gameController.decreaseScore();
      }
    } else if (mouseButton == RIGHT)
    {
      gameController.decreaseScore();
    }
  }
}

void updateGeneralTime()
{
  elapsedTimeGeneral = (int)(millis()/1000.0);
}

void updateGameTime()
{
  gameController.gameTime = elapsedTimeGeneral - elapsedTimeStart;
}

void checkCollision()
{
  boolean hit = false;

  for (int i = 0; i < gameController.enemies.length; i++)
  {
    Enemy enemy = gameController.enemies[i];

    PVector mouseRay = gameController.ScreenToWorldRay(mouseX / (float)width * 2f - 1f,
      (1f - mouseY / (float) height) * 2f - 1f);

    float dist = gameController.raySphereIntersect(camVector, mouseRay, new PVector(enemy.centerX * scale, enemy.centerY * scale, enemy.centerZ * scale), 20f * scale);

    if (dist > -1)
    {
      if (!enemy.hit && enemy.isActive && !enemy.isDead)
      {
        enemy.hit = true;
        hit = true;
      }
    } else
    {
      enemy.hit = false;
    }
  }

  if (hit)
    println(hit);
}
