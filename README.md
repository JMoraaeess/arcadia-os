<p align="center">
  <img src="assets/arcadia-os-logo.jpg" alt="ArcadiaOS Logo" width="380" style="border-radius: 24px; box-shadow: 0 8px 32px rgba(0,0,0,0.5);" />
</p>

<h1 align="center">ArcadiaOS 🏛️🎮📺</h1>

<p align="center">
  <strong>The Living Room Powerhouse</strong>: Unified PC Console Experience & Native Smart TV Runtime.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Linux%20%7C%20Bazzite-blue" alt="Platform" />
  <img src="https://img.shields.io/badge/Architecture-x86__64-orange" alt="Architecture" />
  <img src="https://img.shields.io/badge/Android%20TV-Waydroid%20Leanback-green" alt="Android TV" />
  <img src="https://img.shields.io/badge/License-MIT-purple" alt="License" />
</p>

---

**ArcadiaOS** is an open-source project designed to turn any PC into the ultimate living room console and media center. Built on top of immutable gaming Linux foundations (like Bazzite), ArcadiaOS seamlessly bridges high-performance AAA PC gaming with a dedicated, hardware-accelerated **Android TV runtime (Waydroid Leanback)** for native smart TV streaming apps, full D-pad remote navigation, and hardware spoofing for uncompromised media playback.


---

## 🌟 Key Features

* **🔀 Arcadia Dual Portal (Boot Selector):** Splitscreen startup UI on boot to choose between **JOGOS** and **SMART TV** with Gamepad or TV Remote.
* **🎮 Native PC Gaming (Console Mode):** Boots straight into full-screen Game Mode with low-latency controller support, suspend/resume, and native GPU acceleration (Nvidia & AMD).
* **📺 Real Android TV Interface:** Runs genuine Android TV applications (Projectivy Launcher, SmartTube 4K, TV streaming APKs) designed specifically for 10-foot TV viewing.
* **🏪 Native TV App Stores:** Built-in Google Play Store (GApps with Play Protect certification) and Aurora Store TV for zero-friction TV APK downloads.
* **🕹️ Bluetooth Remote Control First:** Full out-of-the-box support for Bluetooth TV remotes (such as the standard G9N9N Bluetooth remote).
* **⚡ ARM-to-x86 Translation (`libndk`):** Seamlessly executes ARMv7 / ARM64 Android TV APKs on standard x86_64 PC processors.
* **🛡️ Hardware Identity Spoofing:** Injects certified TV hardware profiles (NVIDIA SHIELD TV `mdarcy`) to unlock the official TV catalog from the Play Store.
* **🪟 Automated UEFI Dual-Boot:** Auto-detects your existing Windows installation, adds it to the GRUB boot menu with 1080p/4K resolution for TVs, and remembers your last boot choice.
* **💾 Safe Secondary Drive Installation:** Installs cleanly on a secondary HDD or SSD without altering your primary Windows drive.

---

## 📁 Repository Structure

```text
arcadia-os/
├── bin/
│   ├── arcadia-launcher.sh         # Launcher session handler for Waydroid TV
│   └── arcadia-portal.sh           # Kiosk launcher for the Boot Selector
├── config/
│   ├── arcadia-portal.desktop      # Autostart entry for the boot selector
│   ├── arcadia-tv.desktop          # Application entry for Game Mode / Desktop
│   ├── shield-props.prop           # Hardware spoofing profile (NVIDIA Shield TV)
│   └── 99-bt-remote.rules          # Low-latency udev rules for Bluetooth remotes
├── portal/
│   ├── index.html                  # Responsive 4K Split-Screen UI (Gamepad + Remote)
│   └── server.py                   # Lightweight Python bridge and API server
├── scripts/
│   ├── install.sh                  # Interactive Master Installer (1-click)
│   ├── setup-dualboot.sh           # Automated Windows UEFI dual-boot configurator
│   ├── setup-waydroid-tv.sh        # Automated Android TV container provisioning
│   └── setup-remote.sh             # Bluetooth TV remote pairing assistant
├── LICENSE                         # MIT Open Source License
└── README.md                       # Main documentation
```

---

## 🛠️ Guia de Instalação Passo a Passo (Step-by-Step Guide)

Siga este roteiro prático para configurar o **ArcadiaOS** no seu PC da sala, mantendo o seu Windows 100% seguro em **Dual-Boot**:

### 1️⃣ Passo 1: Baixar a Imagem ISO Oficial (Bazzite Linux)
Acesse o seletor oficial de imagens em: **[bazzite.gg](https://bazzite.gg)**

* **Tipo de Equipamento (Hardware):**
  * Selecione **`Desktop PC`** (ou `Handheld PC` se estiver usando um PC portátil como ROG Ally / Legion Go).

* **Escolha da GPU (Conforme o seu computador):**
  * 🟢 **NVIDIA (GeForce GTX / RTX dedicadas):**  
    Selecione **`NVIDIA`**.  
    *(Já vem com os drivers proprietários estáveis da NVIDIA compilados no kernel).*
  * 🔴 **AMD (Radeon RX dedicada ou APUs Ryzen / Athlon com gráficos integrados Vega / RDNA):**  
    Selecione **`AMD`**.  
    *(Utiliza drivers open-source Mesa com suporte nativo a Vulkan e HDR).*
  * 🔵 **Intel (Placas dedicadas Intel Arc ou Gráficos Integrados Intel UHD / Iris Xe):**  
    Selecione **`Intel`**.  
    *(Utiliza os drivers Mesa Intel de alto desempenho).*

* **Interface Gráfica (DE):**  
  Selecione **`KDE Plasma`** *(recomendado para navegação fluida em TVs, controle remoto e escalabilidade 4K).*

* Clique em **Download ISO**.


---

### 2️⃣ Passo 2: Gravar o Pendrive de Inicialização
1. Baixe o gravador de imagem: **[BalenaEtcher](https://etcher.balena.io/)** ou **[Rufus](https://rufus.ie/)** no Windows.
2. Conecte um pendrive de pelo menos **8GB**.
3. Selecione o arquivo ISO baixado e clique em **Flash / Gravar**.

---

### 3️⃣ Passo 3: Instalação Segura no Disco Secundário (Sem apagar o Windows)
1. Conecte o pendrive no PC e ligue pressionando a tecla de Boot Menu da sua placa-mãe (`F8`, `F11` ou `F12`).
2. Selecione o pendrive em modo **UEFI**.
3. Na tela de particionamento e discos do instalador:
   > [!IMPORTANT]
   > **Atenção na Seleção do Disco:**  
   > Escolha exclusivamente o seu **SSD ou HD secundário**. **NÃO selecione o disco do Windows**, garantindo que seus arquivos pessoais e sua instalação original continuem intactos.
4. Conclua a instalação e reinicie o PC.

---

### 4️⃣ Passo 4: Executar o Instalador de 1 Clique do ArcadiaOS
Ao entrar no sistema instalado pela primeira vez:
1. Abra o terminal (**Konsole**) e rode o comando oficial:

```bash
curl -fsSL https://raw.githubusercontent.com/JMoraaeess/arcadia-os/main/scripts/install.sh | bash
```

*(Ou via clone manual do repositório):*
```bash
git clone https://github.com/JMoraaeess/arcadia-os.git
cd arcadia-os && chmod +x scripts/install.sh && ./scripts/install.sh
```

> [!TIP]
> **O instalador cuida de tudo sozinho:**
> - 🪟 Configura o **Dual-Boot (ArcadiaOS & Windows)** no menu UEFI com resolução 1080p nítida para TV.
> - 🔀 Instala o **Arcadia Dual Portal (Tela Dividida)** ao ligar o PC para escolher entre **JOGOS** e **SMART TV**.
> - 📺 Provisiona o subsistema **Android TV (Waydroid Leanback)** em tela cheia com aceleração gráfica.
> - 🛡️ Injeta o perfil de hardware **NVIDIA SHIELD TV Pro** para liberar apps de streaming de TV oficiais.
> - 🏪 Instala as lojas **Google Play Store** (com ativador Play Protect) e **Aurora Store TV**.
> - ⚡ Configura os drivers e aceleração gráfica automaticamente para sua GPU (NVIDIA, AMD ou Intel).
> - 🕹️ Inicia o assistente de pareamento para o seu **Controle Remoto Bluetooth**.

---

### 5️⃣ Passo 5: Como Usar no Dia a Dia da Sala

1. **Ao ligar o PC:**  
   O menu inicial do GRUB aguarda 5 segundos para você escolher entre **ArcadiaOS** e **Windows Boot Manager** (ele memoriza sua última escolha automaticamente).
2. **Ao entrar no ArcadiaOS:**  
   Abre-se o **Dual Portal** em tela dividida:
   * Escolha **🎮 JOGOS** usando o direcional do Gamepad para abrir o Steam Big Picture / Game Mode.
   * Escolha **📺 SMART TV** usando o Controle Remoto para abrir o Projectivy Launcher com seus apps de streaming e canais.


---

## 🎮 Recommended Hardware Setup

| Component | Recommendation |
| :--- | :--- |
| **GPU / APU** | NVIDIA GeForce (GTX / RTX), AMD Radeon / APU Ryzen, or Intel Arc / Iris Xe |
| **Storage** | Dedicated 500GB - 1TB+ SSD or HDD |
| **Controller** | Standard Gamepad (Xbox / PlayStation) for Gaming |
| **Remote** | Bluetooth TV Remote (G9N9N or compatible BLE remote) |
| **Connectivity** | Bluetooth 4.2+ & Ethernet / Wi-Fi |

---

## 📄 License & Legal Disclaimer

Distributed under the MIT License. See `LICENSE` for more information.

> [!NOTE]
> **Trademarks & Disclaimer:**  
> Steam, SteamOS, and Steam Deck are trademarks or registered trademarks of Valve Corporation.  
> Android, Google Play, and Android TV are trademarks of Google LLC.  
> NVIDIA and SHIELD are trademarks or registered trademarks of NVIDIA Corporation.  
> ArcadiaOS is an independent, community-driven open-source project. It is not affiliated with, endorsed by, or sponsored by Valve Corporation, Google LLC, NVIDIA Corporation, or any other trademark holder mentioned herein.

