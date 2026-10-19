# 🎲 斗罗命运转盘 (Douluo Destiny Wheel)

<div align="center">

![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)
![Version](https://img.shields.io/badge/Version-v1.9.0-FF6F00?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)

**斗罗大陆全时代命运转盘人生模拟器**  
转动命运之轮，重走成神之路！从武魂觉醒到神位九考，体验千变万化的魂师生涯。

[📱 下载体验](#-客户端下载) • [✨ 核心特色](#-核心特色与玩法系统) • [🚀 快速开始](#-快速开始与编译) • [🏗️ 项目架构](#️-项目架构) • [📝 更新日志](https://github.com/qjngbac/douluo-wheel-life/releases)

</div>

---

## 📖 游戏简介

《斗罗命运转盘》（Douluo Destiny Wheel / douluo_wheel_life）是一款基于 **Flutter** 框架打造的文字冒险与人生模拟游戏。

游戏融合了**命运转盘**机制与深度数值成长系统，完美还原《斗罗大陆》经典世界观。每一世人生，玩家都可以选择不同的时代背景、出身与修炼道路。随着岁月的流逝与命运转盘的转动，大吉、大凶、奇遇、天劫与机缘接踵而至，带给你充满沉浸感与多重分支的人生奇遇！

---

## ✨ 核心特色与玩法系统

### 1. 🎯 命运转盘机制
- 游戏核心行动由**命运转盘**驱动：**大吉、吉、平、凶、大凶、奇遇**。
- 转盘由高性能自绘 Canvas 渲染，指针与旋转物理平滑丝滑，命中事件根据角色气运、时代环境与当前实力动态加权。
- 逆天改命还是劫难加身？每一次转动都是对命运的未知抉择！

### 2. ⏳ 跨越斗罗四大时代
- **斗罗大陆（初代荣光）**：唐门初立，武魂殿横压当世，上三宗各显威名。
- **绝世唐门（魂导崛起）**：日月大陆碰撞，魂导科技与传灵塔初现峥嵘。
- **龙王传说（机甲时代）**：魂导机甲普及，斗铠铸造，深渊位面威胁降临。
- **终极斗罗（星际联邦）**：星际探索，天龙星系碰撞，龙神归位之战。

### 3. 🧬 双线成长道路
- **人类魂师路线**：
  - **武魂觉醒**：海量原著武魂（昊天锤、六翼天使、蓝银皇、蓝电霸王龙、邪火凤凰、九宝琉璃塔等），更有概率觉醒神级**双生武魂**！
  - **魂环吸收**：十年白、百年黄、千年紫、万年黑、十万年红直至百万年神级魂环，自由搭配魂技组合。
  - **魂骨融身**：六大正统魂骨位与稀世外附魂骨（如八蛛矛），属性与专属被动全面加成。
  - **神位九考**：突破百级极限，开启海神、修罗神、天使神、罗刹神、情绪之神等神位考核，最终登临神界！
- **魂兽化形路线**：
  - 凶兽血脉起步，历经十万年渡劫苦修；
  - 抉择保留兽身逆天抗劫，或是化为人形重修魂师，品味人间百态与情感羁绊。

### 4. 👥 32+ 原著经典角色专属羁绊
- 深度还原原著传奇人物：唐三、小舞、戴沐白、朱竹清、比比东、千仞雪、霍雨浩、王冬儿、唐舞桐、唐舞麟、古月娜、蓝轩宇、白秀秀等。
- 每位角色拥有专属的**原著身份称号**与**专属剧情羁绊事件**（如冰火两仪眼仙草馈赠、天水相逢、神考护法、生死并肩等），绝非千篇一律的模板路人！

### 5. ⚡ 动态防重复机制与智能冷却（v1.9.0 突破）
- **人生事件智能去重**：彻底解决同类人际事件频繁刷屏的问题，引入年龄段过滤、触发冷却时间（Cooldown）与终身触发上限；
- **真实成长逻辑**：幼年期、学院期、游历期、神考期事件合理分配，不会再出现“百岁神匠重返初级学院”等时空混乱违和感。

### 6. 🔄 多世轮回与成就殿堂
- **多世轮回反哺**：前世成就与最终境界可转化为轮回点数与气运加成，为后世子嗣奠定更强起点；
- **成就长廊与历史生平**：详尽记录每一世的人生传记、魂环配置、击败强敌与最终结局，随时回味自己的斗罗传奇。

---

## 📱 客户端下载

你可以在本仓库的 [**GitHub Releases**](https://github.com/qjngbac/douluo-wheel-life/releases) 页面下载最新构建好的安装包：

| 安装包文件 (Release Asset) | 适用架构 | 体积 | 特点说明 |
| :--- | :--- | :--- | :--- |
| **`DouluoWheelLife-v1.9.0-arm64-v8a.apk`** | arm64-v8a (64位) | ~17.7 MB | 专为现代 64 位手机优化的架构包，体积大幅精简 65%，推荐主流安卓手机使用 |

> **系统要求**：Android 5.0 (API Level 21) 及以上版本。

---

## 🚀 快速开始与编译

本项目基于标准 Flutter 架构开发，使用 Dart 语言编写，纯前端无外部重型后端依赖，即下即测即玩。

### 环境准备
- **Flutter SDK**: `>= 3.12.0` (推荐 Flutter 3.24+ / 3.44+)
- **Dart SDK**: `>= 3.12.2`
- **JDK**: OpenJDK 17 或 21
- **Android SDK**: API Level 34+

### 获取代码与运行

```bash
# 1. 克隆代码仓库
git clone https://github.com/qjngbac/douluo-wheel-life.git
cd douluo-wheel-life

# 2. 获取依赖包
flutter pub get

# 3. 连接安卓手机或模拟器进行调试运行
flutter run
```

### 构建正式发布包 (Release APK)

```bash
# 构建全架构通用安装包
flutter build apk --release

# 构建针对现代手机的高性能 64 位精简版
flutter build apk --release --target-platform android-arm64 --split-per-abi
```

---

## 🏗️ 项目架构

项目严格遵循数据驱动与关注点分离（SoC）原则，结构清晰易维护：

```text
lib/
├── app.dart                   # 应用根组件与全局主题配置
├── main.dart                  # 应用入口点
├── data/                      # 核心数据驱动模型与配置库
│   ├── canon_event_data.dart      # 原著史诗级大事件库
│   ├── creation_data.dart         # 开局创建、武魂、先天属性数据
│   ├── era_character_data.dart    # 32位原著角色与专属羁绊配置
│   ├── era_data.dart              # 四大时代环境特征与规则
│   ├── era_milestone_data.dart    # 时代历史进程与里程碑事件
│   ├── godhood_data.dart          # 各系神位、神考阶段与神技配置
│   ├── relationship_arc_data.dart # 人际社交关系与多阶段好感羁绊
│   ├── ring_data.dart             # 魂环魂技库与年份规则
│   ├── soul_beast_data.dart       # 魂兽种族、天劫与修行系统
│   ├── soul_spirit_data.dart      # 魂灵系统与契约机制
│   └── story_data.dart            # 人生转盘事件池与冷却规则引擎
├── domain/                    # 领域实体模型 (角色/武魂/魂环/战利品等)
├── engine/                    # 游戏逻辑引擎 (转盘概率、事件调度、战力运算)
├── state/                     # 状态管理层 (角色当前生平状态与控制器)
├── storage/                   # 持久化存档、成就殿堂与轮回数据存储
└── ui/                        # 用户交互界面
    ├── components/                # 动态转盘Canvas、魂环展示等核心UI组件
    └── screens/                   # 主页、游戏主界面、结局结算、图鉴存档页
```

---

## 📝 贡献与反馈
 
欢迎任何对斗罗大陆题材或人生模拟游戏感兴趣的开发者提出建议与改进！
- 如果你发现了 Bug 或有好的玩法建议，欢迎提交 [Issues](https://github.com/qjngbac/douluo-wheel-life/issues)。
- 如果你希望增加新的原著武魂、神位考评或时代事件，欢迎提交 Pull Request。

---

## 📄 开源协议

本项目采用 [MIT License](LICENSE) 开源。

*声明：本项目仅供编程学习、技术交流与同好娱乐，游戏中所涉及的《斗罗大陆》相关设定、角色名字及背景知识版权归原作者唐家三少及相关版权方所有。*
