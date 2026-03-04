import java.io.PrintWriter;
import java.io.File;
import java.util.ArrayList;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class DataGenerator {

    static float random(float min, float max) {
        return min + (float)Math.random() * (max - min);
    }

    public static void main(String[] args) {
        float timeStep = 0.05f;
        float G = 10.0f;
        int maxTicks = 100000;
        int maxEpisodes = 100000;
        
        try {
            LocalDateTime now = LocalDateTime.now();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH_mm_ss");
            String currentTime = now.format(formatter);
            
            String filename = "_dt_" + timeStep + "_G_" + G + "_maxTicks_" + maxTicks + "_nbody_data_" + currentTime + ".csv";
            PrintWriter output = new PrintWriter(new File(filename));
            output.println("cmx,cmy,cmz,m1,x1,y1,z1,vx1,vy1,vz1,m2,x2,y2,z2,vx2,vy2,vz2,m3,x3,y3,z3,vx3,vy3,vz3,cmxf,cmyf,cmzf,x1f,y1f,z1f,vx1f,vy1f,vz1f,x2f,y2f,z2f,vx2f,vy2f,vz2f,x3f,y3f,z3f,vx3f,vy3f,vz3f,ticks");

            for (int episode = 0; episode < maxEpisodes; episode++) {
                ArrayList<Planet> planets = new ArrayList<Planet>();
                Vec3 zeroVec = new Vec3(0, 0, 0);

                for (int i = 0; i < 3; i++) {
                    Vec3 pos = new Vec3(random(-50, 50), random(-50, 50), random(-50, 50));
                    Vec3 vel = new Vec3(random(-5, 5), random(-5, 5), random(-5, 5));
                    float mass = random(10.0f, 30.0f);
                    planets.add(new Planet(pos, vel, zeroVec, mass, 0));
                }

                for (Planet a : planets) {
                    float potential = 0.0f;
                    for (Planet b : planets) {
                        if (a == b) continue;
                        Vec3 distVec = Vec3.sub(b.pos, a.pos);
                        float r = distVec.mag();
                        potential -= (G * a.mass * b.mass) / r;
                    }

                    float kinetic = 0.5f * a.mass * a.vel.mag() * a.vel.mag();
                    if (kinetic >= -potential) {
                        float maxV = (float)Math.sqrt((2.0f * 0.8f * -potential) / a.mass);
                        a.vel.normalize();
                        a.vel.scale(random(0.1f, maxV));
                    }
                }

                Universe universe = new Universe(planets, timeStep, G);
                universe.findCenter();
                
                String initialConditions = universe.cm.x + "," + universe.cm.y + "," + universe.cm.z + ",";
                for (Planet p : planets) {
                    initialConditions += p.mass + "," + p.pos.x + "," + p.pos.y + "," + p.pos.z + "," +
                                         p.vel.x + "," + p.vel.y + "," + p.vel.z + ",";
                }

                int ticks = 0;
                while (ticks < maxTicks && !universe.isSystemUnstable()) {
                    universe.update();
                    ticks++;
                }

                String finalState = universe.cm.x + "," + universe.cm.y + "," + universe.cm.z + ",";
                for (Planet p : planets) {
                    finalState += p.pos.x + "," + p.pos.y + "," + p.pos.z + "," +
                                  p.vel.x + "," + p.vel.y + "," + p.vel.z + ",";
                }

                output.println(initialConditions + finalState + ticks);
            }

            output.flush();
            output.close();
            System.out.println("Data generation complete.");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}