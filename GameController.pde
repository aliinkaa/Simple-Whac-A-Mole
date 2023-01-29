 class GameController
{
  public float camZ;

  GameState gameState = GameState.GAMESTART;
  boolean gameEnded = false;

  String fontName = "PublicPixel-z84yD.ttf";
  PFont gameFontBig;
  PFont gameFontSmall;
  int fontSizeBig = 28;
  int fontSizeSmall = 14;
  int offsetUI = 50;
  color colorUI;
  color barColor;
  
  color barCornerColor;
  color barFillingColor;

  int timerDuration = 40;
  int gameTime = 0;
  int gameScale = 4;
  int smoothing = 0; //for time bar.
  float fillAmount;
  float prevFillAmount = 0;
  float smoothingThreshold; //for bar.

  int playerScore = 0;
  int scoreIncrease = 15;
  int scoreDecrease = 20;

  Enemy[] enemies;
  ArrayList<Enemy> enemiesList;
  PImage[] imgTextures;
  int imgCount = 10;
  int enemyCount = 9;
  int aliveEnemyCount;
  float enemyHeight = 60;
  float enemyRadius = 20;

  PImage testTexture;

  public GameController()
  {
    enemies = new Enemy[enemyCount];
    //testTexture = loadImage("sonicoBeach.png");
    enemiesList = new ArrayList<Enemy>();
  }

  public void gameSettings()
  {
    camZ = (height/2.0) / tan(PI*30.0 / 180.0);
    
    colorUI = color(150, 0, 24);
    barColor = color(210, 31, 60);
    barCornerColor = color(210, 210, 210);
    barFillingColor = color(153, 153, 153);
    
    aliveEnemyCount = enemyCount;
    smoothingThreshold = ((float)timerDuration - 1) / (float)timerDuration;
    print(smoothingThreshold);
    
    gameFontBig = createFont(gameController.fontName, gameController.fontSizeBig);
    gameFontSmall = createFont(gameController.fontName, gameController.fontSizeSmall);
    //textFont(gameFontBig);
    textAlign(LEFT);
    
    textureMode(NORMAL);
    loadTextures();
    spawnEnemies();
  }

  void loadTextures()
  {
    imgTextures = new PImage[imgCount];

    for (int a = 0; a < imgTextures.length; a++)
    {
      String num = Integer.toString(a);
      String fileName = num + ".jpeg";
      imgTextures[a] = loadImage(fileName);
    }
  }

  public void renderEndUI(boolean hasWon)
  {
    hint(DISABLE_DEPTH_TEST);

    noLights();
    camera();
    fill(colorUI);

    if (hasWon)
    {
      //won.
      endWinUI();
    } else
    {
      //lost.
      endLoseUI();
    }

    hint(ENABLE_DEPTH_TEST);
  }

  void endWinUI()
  {
    textAlign(CENTER);
    text("Killed all the enemies, you won! <3", width/2, height/2);
    text("Your score : " + playerScore, width/2, height/2 + height/7);
  }

  void endLoseUI()
  {
    textAlign(CENTER);
    text("You've lost! Bye bye :(", width/2, height/2);
    text("Your score : " + playerScore, width/2, height/2 + height/7);
  }

  public void renderGameUI()
  {
    // 2D
    hint(DISABLE_DEPTH_TEST);

    noLights();
    camera();
    fill(colorUI);

    if (gameState == GameState.GAMESTART)
      startUI();
      
    textFont(gameFontBig);
    timerUI();
    scoreUI();
    controlsUI();
    textFont(gameFontBig);
    timeBar();
    
    hint(ENABLE_DEPTH_TEST);
  }

  void timerUI()
  {
    textAlign(LEFT);
    text("Time : " + gameTime, 100, 100);
  }

  void scoreUI()
  {
    textAlign(RIGHT);
    text("Score : " + playerScore, width - 100, 100);
  }

  void startUI()
  {
    textAlign(CENTER);
    text("Press any key to start!", width/2, 250);
  }

  void timeBar()
  {
    //corners.
    fill(barCornerColor);
    noStroke();
    rectMode(CORNER);
    rect(100, 120, 150, 30, 72);

    fill(barFillingColor);
    noStroke();
    rectMode(CORNER);
    rect(105, 125, 140, 20, 72);

    //fill image.
    fill(barColor);
    noStroke();
    rectMode(CORNER);


    fillAmount = ((float)gameTime / (float)timerDuration);

    if (fillAmount >= 1)
    {
      fillAmount = 1;
    }
    if (fillAmount > smoothingThreshold)
    {
      smoothing = 1; //do smooth;
    }

    rect(105, 125, 140 * fillAmount, 20, 72, 72 * smoothing, 72 * smoothing, 72);
  }
  
  void controlsUI()
  {
    textFont(gameFontSmall);
    textAlign(LEFT);
    text("Shooting : LMB", 100, height - 90);
    text("Rotation : L/R Arrow Keys", 100, height - 70);
    text("Zoom : U/D Arrow Keys", 100, height - 50);
  }
    
  public void updateGameTime(int time)
  {
    gameTime = time;
  }

  public void setGameState(GameState state)
  {
    gameState = state;
  }

  public void spawnEnemies()
  {
    float offset = 10;
    float offsetX = enemyRadius * 2 + offset; //radius * 2 + offset
    float offsetZ = enemyRadius * 2 + offset;

    float firstX = -(offsetX * (float)(sqrt(enemyCount) - 1))/2.0;
    float firstY = -10;
    float firstZ = -(offsetX * (float)(sqrt(enemyCount) - 1))/2.0;

    for (int i = 0; i < sqrt(enemyCount); i++)
    {
      for (int a = 0; a < sqrt(enemyCount); a++)
      {
        Enemy enemy = new Enemy(testTexture, gameScale, enemyHeight, enemyRadius);
        enemy.imgTexture = imgTextures[(int)random(0, imgCount)];
        enemy.posX = firstX + offsetX * a;
        enemy.posY = firstY;
        enemy.posZ = firstZ + offsetZ * i;
        enemiesList.add(enemy);
      }
    }

    for (int b = 0; b < enemyCount; b++)
    {
      enemies[b] = enemiesList.get(b);
    }
  }

  public void renderEnemies()
  {
    for (int i = 0; i < enemies.length; i++)
    {
      if(enemies[i].doRender)
        enemies[i].enemyAnimation();
    }
  }

  public void activateEnemies()
  {
    int enemyCount = ((int) random(2)) + 1;
    enemyCount = min(enemyCount, aliveEnemyCount);

    for (int i = 0; i < enemyCount; i++)
    {
      boolean picked = false;

      while (!picked)
      {
        int index = (int)random(0, enemies.length);
        Enemy enemy = enemies[index];

        if (!enemy.isActive && !enemy.isDead)
        {
          enemy.activate();
          picked = true;
        }
      }
    }
  }

  public void gameEndCheck()
  {

    if (gameTime >= timerDuration)
    {
      //time ran out --> enemies left : lose / no enemies : win
      if (aliveEnemyCount <= 0)
      {
        gameState = GameState.GAMEEND_WIN;
      } else
      {
        gameState = GameState.GAMEEND_LOSE;
      }
    } else if (aliveEnemyCount <= 0)
    {
      //all enemies killed --> time left(should be as, in here) : win
      gameState = GameState.GAMEEND_WIN;
    }
  }

  public boolean gameEnded()
  {
    if (gameState == GameState.GAMEEND_WIN || gameState == GameState.GAMEEND_LOSE)
      gameEnded = true;

    return gameEnded;
  }

  public void increaseScore()
  {
    playerScore += scoreIncrease;
  }

  public void decreaseScore()
  {
    playerScore -= scoreDecrease;

    if (playerScore < 0)
    {
      playerScore = 0;
    }
  }

  public void removeEnemy(Enemy enemy)
  {
    println("I 'removeEnemy' worked!");
    enemy.die();
    aliveEnemyCount--;

    increaseScore();
  }
  
  float raySphereIntersect(PVector r0, PVector rd, PVector s0, float sr)
  {
    // - r0: ray origin (camera pos)
    // - rd: normalized ray direction (ScreenToWorldRay return)
    // - s0: sphere center (Cylinder center)
    // - sr: sphere radius (Hardcode)
    // - Returns distance from r0 to first intersecion with sphere,
    //   or -1.0 if no intersection.

    float a = PVector.dot(rd, rd);
    PVector s0_r0 = PVector.sub(r0, s0);
    float b = 2.0 * PVector.dot(rd, s0_r0);
    float c = PVector.dot(s0_r0, s0_r0) - (sr* sr);
    if (b * b - 4.0 * a * c < 0.0) 
    {
      return -1.0;
    }
    return (-b - sqrt((b * b) - 4.0 * a * c))/(2.0*a);
  }
  
  // Direction vector near/far plane
  PVector ScreenToWorldRay(float winX, float winY)
  {
    PMatrix3D projection = ((PGraphics3D)g).projection;
    PMatrix3D modelview = ((PGraphics3D)g).modelview;

    PMatrix3D resMat = new PMatrix3D();
    resMat.apply(projection);
    resMat.apply(modelview);
    resMat.invert();

    float[] nearIn = {winX, winY, -1, 1.0f};
    float[] farIn = {winX, winY, 1, 1.0f};

    float[] nearOut = new float[4];
    float[] farOut = new float[4];

    resMat.mult(nearIn, nearOut);
    resMat.mult(farIn, farOut);

    PVector nearRes = new PVector(nearOut[0]/nearOut[3], nearOut[1]/nearOut[3], nearOut[2]/nearOut[3]);
    PVector farRes = new PVector(farOut[0]/farOut[3], farOut[1]/farOut[3], farOut[2]/farOut[3]);

    farRes.sub(nearRes);
    farRes.normalize();
    return farRes;
  }
}
