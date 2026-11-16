/**
 * 武大风景图元数据
 * 所有图片均来自 Wikimedia Commons 的开放授权素材，本地化存放于 src/assets/scenery/。
 * 详细来源、作者、许可见根目录 ATTRIBUTION.md。
 *
 * 每条记录：file(本地名)、scene 中英、location、author、license、commonsUrl
 */

export type Scenery = {
  /** 本地文件名，对应 src/assets/scenery/<file> */
  file: string;
  /** 景点中文名 */
  scene_cn: string;
  /** 景点英文名（排印用） */
  scene_en: string;
  /** 取景地 */
  location: string;
  /** 作者（按 Commons 署名） */
  author: string;
  /** 许可 */
  license: string;
  /** Commons 文件描述页 */
  commonsUrl: string;
};

export const scenery: Scenery[] = [
  {
    file: "sakura-castle.jpg",
    scene_cn: "樱花城堡",
    scene_en: "Sakura Castle",
    location: "武汉大学 · 樱顶",
    author: "Howchou",
    license: "CC BY 4.0",
    commonsUrl: "https://commons.wikimedia.org/wiki/File:Wuhan_University_Sakura_Castle.jpg",
  },
  {
    file: "sakura-castle-2.jpg",
    scene_cn: "樱花城堡",
    scene_en: "Sakura Castle",
    location: "武汉大学 · 樱顶",
    author: "Howchou",
    license: "CC BY 4.0",
    commonsUrl: "https://commons.wikimedia.org/wiki/File:Wuhan_University_Sakura_Castle_2.jpg",
  },
  {
    file: "old-library.jpg",
    scene_cn: "老图书馆",
    scene_en: "Old Library",
    location: "武汉大学 · 樱顶",
    author: "Howchou",
    license: "CC BY-SA 3.0",
    commonsUrl: "https://commons.wikimedia.org/wiki/File:Wuhan_University_Old_Library.jpg",
  },
  {
    file: "laojishe-gate.jpg",
    scene_cn: "老斋舍拱门",
    scene_en: "Laojishe Archway",
    location: "武汉大学 · 老斋舍",
    author: "谢宇杰",
    license: "CC BY-SA 4.0",
    commonsUrl: "https://commons.wikimedia.org/wiki/File:Wuhan_University_Dormitory_Gate.jpg",
  },
  {
    file: "administration.jpg",
    scene_cn: "行政楼",
    scene_en: "Administration Building",
    location: "武汉大学",
    author: "Howchou",
    license: "CC BY 4.0",
    commonsUrl: "https://commons.wikimedia.org/wiki/File:Wuhan_University_Administration_Building.jpg",
  },
  {
    file: "gate.jpg",
    scene_cn: "校门牌坊",
    scene_en: "University Gate",
    location: "武汉大学",
    author: "Howchou",
    license: "CC BY 4.0",
    commonsUrl: "https://commons.wikimedia.org/wiki/File:Wuhan_University_Gate.jpg",
  },
  {
    file: "wanlin.jpg",
    scene_cn: "万林艺术博物馆",
    scene_en: "Wanlin Art Museum",
    location: "武汉大学",
    author: "Doraemon.tvb",
    license: "CC BY-SA 3.0",
    commonsUrl: "https://commons.wikimedia.org/wiki/File:Wanlin_Art_Museum.jpg",
  },
  {
    file: "donghu-dusk.jpg",
    scene_cn: "东湖夕照",
    scene_en: "Donghu at Dusk",
    location: "武汉 · 东湖",
    author: "そらみみ",
    license: "CC BY-SA 4.0",
    commonsUrl: "https://commons.wikimedia.org/wiki/File:Donghu_Lake_at_dusk.jpg",
  },
];
