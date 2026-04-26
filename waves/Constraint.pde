interface Constraint {
  void resolve();
  boolean isBroken();
  void display();
}

class SpringConstraint implements Constraint {
  Node n1, n2;
  float restLength;
  float stiffness;
  float stretchLimit;
  boolean broken = false;
  
  SpringConstraint(Node n1, Node n2, float stiffness, float stretchLimit) {
    this.n1 = n1;
    this.n2 = n2;
    this.restLength = PVector.dist(n1.pos, n2.pos);
    this.stiffness = stiffness;
    this.stretchLimit = stretchLimit;
  }
  
  void resolve() {
    if (broken) return;
    
    PVector delta = PVector.sub(n2.pos, n1.pos);
    float currentLength = delta.mag();
    
    if (stretchLimit > 0 && currentLength > restLength * stretchLimit) {
      broken = true;
      return;
    }
    
    float diff = (restLength - currentLength) / currentLength;
    PVector offset = PVector.mult(delta, diff * stiffness * 0.5f);
    
    if (!n1.isPinned) n1.pos.sub(offset);
    if (!n2.isPinned) n2.pos.add(offset);
  }
  
  boolean isBroken() {
    return broken;
  }
  
  void display() {
    if (broken) return;
    stroke(Settings.CONSTRAINT_COLOR);
    strokeWeight(1);
    line(n1.pos.x, n1.pos.y, n1.pos.z, n2.pos.x, n2.pos.y, n2.pos.z);
  }
}
