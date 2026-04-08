import java.io.PrintWriter;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.File;
import java.io.IOException;
import java.time.LocalDate;

/**
 * Handles logging of simulation data to CSV files.
 * It can record initial conditions, final states of episodes, and dump current states.
 */
public class SimulationLogger {
    /** The PrintWriter used for logging. */
    public PrintWriter output;
    /** A string representation of the current initial conditions. */
    public String currentInitialConditions = "";

    /**
     * Constructs a new SimulationLogger.
     * 
     * @param fileName the name of the file to log to
     * @param header the header line for the CSV file
     */
    public SimulationLogger(String fileName, String header) {
        try {
            this.output = new PrintWriter(new BufferedWriter(new FileWriter(fileName)));
            this.output.println(header);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Sets and records the initial conditions of the universe.
     * 
     * @param universe the universe to record initial conditions from
     */
    public void setInitialConditions(Universe universe) {
        StringBuilder initConditionsBuilder = new StringBuilder();
        initConditionsBuilder.append(universe.cm.x).append(",").append(universe.cm.y).append(",").append(universe.cm.z).append(",");
        for (Planet p : universe.planets) {
            initConditionsBuilder.append(p.mass).append(",").append(p.pos.x).append(",").append(p.pos.y).append(",").append(p.pos.z).append(",")
                                 .append(p.vel.x).append(",").append(p.vel.y).append(",").append(p.vel.z).append(",");
        }
        this.currentInitialConditions = initConditionsBuilder.toString();
    }

    /**
     * Logs the final state of an episode.
     * 
     * @param universe the universe at the end of the episode
     * @param ticks the number of ticks the episode lasted
     */
    public void logEpisode(Universe universe, int ticks) {
        StringBuilder finalStateBuilder = new StringBuilder();
        finalStateBuilder.append(universe.cm.x).append(",").append(universe.cm.y).append(",").append(universe.cm.z).append(",");
        for (Planet p : universe.planets) {
            finalStateBuilder.append(p.pos.x).append(",").append(p.pos.y).append(",").append(p.pos.z).append(",")
                             .append(p.vel.x).append(",").append(p.vel.y).append(",").append(p.vel.z).append(",");
        }
        this.output.println(this.currentInitialConditions + finalStateBuilder.toString() + ticks);
        this.output.flush();
    }

    /**
     * Closes the log file.
     */
    public void closeLog() {
        if (this.output != null) {
            this.output.close();
        }
    }

    /**
     * Dumps the current state of the simulation to a daily CSV file.
     * 
     * @param universe the current universe
     * @param ticks the current tick count
     * @param folderPath the folder where the dump file should be saved
     */
    public void dumpCurrentState(Universe universe, int ticks, String folderPath) {
        String fileName = folderPath + File.separator + "saved_ics_" + LocalDate.now().toString() + ".csv";
        File file = new File(fileName);
        boolean fileExists = file.exists();

        try {
            PrintWriter dumper = new PrintWriter(new BufferedWriter(new FileWriter(file, true)));
            if (!fileExists) {
                StringBuilder header = new StringBuilder("cmx_0,cmy_0,cmz_0,");
                for (int i = 1; i <= 8; i++) {
                    header.append("m").append(i).append(",x0_").append(i).append(",y0_").append(i).append(",z0_").append(i)
                          .append(",vx0_").append(i).append(",vy0_").append(i).append(",vz0_").append(i).append(",");
                }
                header.append("cmx_f,cmy_f,cmz_f,");
                for (int i = 1; i <= 8; i++) {
                    header.append("x_").append(i).append(",y_").append(i).append(",z_").append(i)
                          .append(",vx_").append(i).append(",vy_").append(i).append(",vz_").append(i).append(",");
                }
                header.append("ticks");
                dumper.println(header.toString());
            }

            StringBuilder finalStateStrBuilder = new StringBuilder();
            finalStateStrBuilder.append(universe.cm.x).append(",").append(universe.cm.y).append(",").append(universe.cm.z).append(",");
            for (int i = 0; i < 8; i++) {
                if (i < universe.planets.size()) {
                    Planet p = universe.planets.get(i);
                    finalStateStrBuilder.append(p.pos.x).append(",").append(p.pos.y).append(",").append(p.pos.z).append(",")
                                        .append(p.vel.x).append(",").append(p.vel.y).append(",").append(p.vel.z).append(",");
                } else {
                    finalStateStrBuilder.append(",,,,,,");
                }
            }
            
            dumper.println(this.currentInitialConditions + finalStateStrBuilder.toString() + ticks);
            dumper.flush();
            dumper.close();
            System.out.println("Saved current state to " + fileName);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}