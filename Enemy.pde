class Enemy
{
  boolean hit = false;
  boolean isDead = false;
  boolean doRender = true;
  
  boolean isActive = false;
  int loopCount = 0;

  PImage imgTexture;

  float posX;
  float posY;
  float posZ;

  float sideHeight;
  float radius;
  int detail = 30;
  float angle; //segment angle.
  float tUnit; //texture unit.
  int scaling;

  float centerX;
  float centerY;
  float centerZ;

  float moveLimitY = 200;
  float moveOffsetY = 0;
  float speed = 1.3;
  float dir = -1;

  //public Enemy(PImage img, float posX, float posY, float posZ)
  public Enemy(PImage img, int scale, float h, float r)
  {
    imgTexture = img;
    scaling = scale;
    sideHeight = h;
    radius = r;
    angle = 360.0 / (float) detail;
    //tUnit = 1.0 / (float) detail;
    tUnit = 1.0 / (float) (detail/2 - 1);
  }

  public void enemyShape()
  {
    for (int i = 0; i < detail; i++)
    {
      /*beginShape(QUADS);
       texture(imgTexture);
       vertex(radius * cos(radians(i * angle)), 0, radius * sin(radians(i * angle)), i * tUnit, 0);
       vertex(radius * cos(radians((i + 1) * angle)), 0, radius * sin(radians((i + 1) * angle)), i * tUnit + tUnit, 0);
       vertex(radius * cos(radians((i + 1) * angle)), sideHeight, radius * sin(radians((i + 1) * angle)), i * tUnit + tUnit, 1);
       vertex(radius * cos(radians(i * angle)), sideHeight, radius * sin(radians(i * angle)), i * tUnit, 1);
       endShape(CLOSE);*/


      if (i <= detail / 2 - 1)
      {
        beginShape(QUADS);
        texture(imgTexture);
        vertex(radius * cos(radians(i * angle)), 0, radius * sin(radians(i * angle)), i * tUnit, 0);
        vertex(radius * cos(radians((i + 1) * angle)), 0, radius * sin(radians((i + 1) * angle)), i * tUnit + tUnit, 0);
        vertex(radius * cos(radians((i + 1) * angle)), sideHeight, radius * sin(radians((i + 1) * angle)), i * tUnit + tUnit, 1);
        vertex(radius * cos(radians(i * angle)), sideHeight, radius * sin(radians(i * angle)), i * tUnit, 1);
        endShape(CLOSE);
      } 
      else
      {
        beginShape(QUADS);
        fill(0);
        vertex(radius * cos(radians(i * angle)), 0, radius * sin(radians(i * angle)));
        vertex(radius * cos(radians((i + 1) * angle)), 0, radius * sin(radians((i + 1) * angle)));
        vertex(radius * cos(radians((i + 1) * angle)), sideHeight, radius * sin(radians((i + 1) * angle)));
        vertex(radius * cos(radians(i * angle)), sideHeight, radius * sin(radians(i * angle)));
        endShape(CLOSE);
      }
    }
    
    stroke(219, 0, 7);
    strokeWeight(1);
    fill(0);
    beginShape();
    for (int i = 0; i < detail; i++)
      vertex(radius * cos(radians(i * angle)), 0, radius * sin(radians(i * angle)));
    endShape(CLOSE);
  }

  public void enemyAnimation()
  {
    noStroke();
    
    if (isActive)
    {
      moveOffsetY += speed * dir;

      if ((-moveOffsetY >= (sideHeight + posY))||(moveOffsetY >= 5))
      {
        dir *= -1;
        loopCount++;
        
        if(loopCount >= 2)
        {
          loopCount = 0;
          isActive = false;
        }
      }
    }

    pushMatrix();
    
    pushMatrix();
    centerX = posX;
    centerY = (posY + moveOffsetY + sideHeight/2.0);
    centerZ = posZ;
    translate(centerX, centerY, centerZ);
    //sphere(20);
    popMatrix();//testingColliders
    
    translate(posX, posY + moveOffsetY, posZ);
    enemyShape();
    popMatrix();
  }
  
  public void die()
  {
    isDead = true;
    doRender = false;
  }
  
  public void activate()
  {
    isActive = true;
  }
}
