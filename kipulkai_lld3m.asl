/*
 * Auto Splitter Script for "Kipulkai : la légende des 3 masques"
 * --------------------------------------------------------------
 * Author: Benoit CHEVILLON for Univers-KiPulKai
 * Website: www.univers-kipulkai.fr
 * GitHub: github.com/BChevillon/kipulkai2_autosplitter
 * Contact: contact@univers-kipulkai.fr
 */


state("uvi") {} // uvi.exe

startup
{
    refreshRate = 100;
    vars.triggers_ids = new List<string>() { "1879061809", "1879062048", "1879062570", "1879062054", "1879062575", "1879063968", "1879063972", "1879063980", "1879063989", "1879063995", "1879063999", "1879064008", "1879064015", "1879064022", "1879064031", "1879064038", "1879064045", "1879062036" }; // Values of all levels
    vars.previousKid1Values = new Dictionary<string, string>();  // Every Kid1 propery, value
    vars.shouldSplit = false;  // Trigger split
    vars.lastConfigTimestamp = DateTime.Now; // Last time configuration.ini was modified
}

update
{
    string directoryPath = Path.GetDirectoryName(game.MainModule.FileName); 
    string filePath = Path.Combine(directoryPath, "configuration.ini"); // Path to configuration.ini
    try
    {
        if (!File.Exists(filePath)) 
        {
            throw new FileNotFoundException("Fichier non trouvé : " + filePath);
        }

        DateTime currentTimestamp = File.GetLastWriteTime(filePath);
        if (currentTimestamp == vars.lastConfigTimestamp) // If file has not been modified
            return;
        vars.lastConfigTimestamp = currentTimestamp;
        string[] lines;
        
        // Read all lines
        lines = File.ReadAllLines(filePath);
        Dictionary<string, string> currentKid1Values = new Dictionary<string, string>();  // Save all kid1 values
        int kid1Index = 0;
        foreach (string line in lines)
        {
            if (line.IndexOf("kid1") == 0)  // If line starts with "kid1"
            {
                string[] keyValue = line.Split('='); // kid1=value
                if (keyValue.Length == 2)
                {
                    string key = "kid1_" + kid1Index;  // Unique key
                    string value = keyValue[1].Trim();
                    currentKid1Values[key] = value;
                    kid1Index++;
                }
            }
        }

        // Compare current values with previous values
        foreach (var entry in currentKid1Values)
        {
            string key = entry.Key;
            string newValue = entry.Value;

            if (!vars.previousKid1Values.ContainsKey(key)) { // Do not trigger first reading
                vars.previousKid1Values[key] = newValue;
                return;
            }

            if (vars.previousKid1Values[key] != newValue)
            {
                vars.previousKid1Values[key] = newValue;   
                if (vars.triggers_ids.Contains(newValue))  // If value is in the list of triggers
                {
                    vars.shouldSplit = true;
                } 
            }
        }

        return; 
    }
    catch (Exception e)
    {
        print(e.Message);
    }
}

split
{
    if (vars.shouldSplit)  // If split is triggered
    {
        vars.shouldSplit = false;
        return true;
    }
    return false;
}