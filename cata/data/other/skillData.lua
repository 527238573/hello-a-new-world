local list = {}


--力量技能

list[#list+1] = {
  id = "melee",
  name = tl("近战","melee"),
  description = tl("在个人战斗中的技能和技巧，不论有没有武器。 高等级可以显著增加物理攻击的准确性和有效性。","Your skill and finesse in personal combat, both with and without a weapon.  Higher levels can significantly increase the accuracy and effectiveness of your physical attacks."),
  main_attr = "str",
}

list[#list+1] = {
  id = "unarmed",
  name = tl("徒手格斗","unarmed combat"),
  description = tl("肉搏战技能。 对于门外汉来说，这是自残的好办法。但有些高手可以用他们特殊的技法来打击和干翻敌人。","Your skill in hand-to-hand fighting.  For the unskilled, it's a good way to get hurt, but those with enough practice can perform special blows and techniques to quickly dispatch enemies."),
  main_attr = "str",
}

list[#list+1] = {
  id = "bashing",
  name = tl("钝击","bashing weapons"),
  description = tl("用钝器战斗的技能，从岩石和棒球棍到步枪枪托都在此列。 等级越高伤害越高，等级较高时也会提高命中。","Your skill in fighting with blunt weaponry, from rocks and sticks to baseball bats and the butts of rifles.  Skill increases damage, and higher levels will improve the accuracy of an attack."),
  main_attr = "str",
}
list[#list+1] = {
  id = "cutting",
  name = tl("劈砍","cutting weapons"),
  description = tl("用砍，劈类型的武器战斗的技能。 较低级别时，等级仅仅决定命中和伤害，而更高级别的技能将有助于穿透重甲和厚皮。","Your skill in fighting with weaponry designed to cut, hack and slash an opponent.  Lower levels of skill increase accuracy and damage, while higher levels will help to bypass heavy armor and thick hides."),
  main_attr = "str",
}
list[#list+1] = {
  id = "stabbing",
  name = tl("穿刺","stabbing weapons"),
  description = tl("用匕，矛等刺击武器战斗的技能。技能增加攻击精度以及造成暴击、致命打击的几率。","Your skill in fighting with knives, spears and other such stabbing implements.  Skill increases attack accuracy as well as the chance of inflicting a deadly and critical blow."),
  main_attr = "str",
}
--感知技能
list[#list+1] = {
  id = "gun",
  name = tl("射击","marksmanship"),
  description = tl("使用弓箭及火器的整体技能。 等级提高会提升使用任何弓或枪支的准确性，但所持武器相对应技能的提升更加明显。","Your overall skill in using bows and firearms.  With higher levels, this general experience increases accuracy with any bows or firearms, but is secondary to practice with the type of ranged weapon in question."),
  main_attr = "per",
}

list[#list+1] = {
  id = "archery",
  name = tl("弓术","archery"),
  description = tl("使用弓的技能。从自制简易弓到复合猎弓，它们安静而有效，但也需要强壮的身体和敏锐的视线。记住，对距离远一点儿的敌人来说，你是在给他们挠痒痒。","Your skill in using bow weapons, from hand-carved self bows to complex hunting crossbows.  Quiet and effective, they require strength of body and sight to wield, and are not terribly accurate over a long distance."),
  main_attr = "per",
}

list[#list+1] = {
  id = "launcher",
  name = tl("重武器","launchers"),
  description = tl("使用像火箭、 榴弹或导弹发射器之类的重型武器的技能。 这些武器用途多样，威力巨大，但他们也很笨重和难用。","Your skill in using heavy weapons like rocket, grenade or missile launchers.  These weapons have a variety of applications and may carry immense destructive power, but they are cumbersome and hard to manage."),
  main_attr = "per",
}

list[#list+1] = {
  id = "pistol",
  name = tl("手枪","handguns"),
  description = tl("相较于步枪，手枪精准度要差一些，但它们的射击速度和装弹速度都比其他枪支快。近身时，它们是非常有效的武器，但不太适合长距离战斗。","Handguns have poor accuracy compared to rifles, but are usually quick to fire and reload faster than other guns.  They are very effective at close quarters, though unsuited for long range engagement."),
  main_attr = "per",
}

list[#list+1] = {
  id = "rifle",
  name = tl("步枪","rifles"),
  description = tl("相比其他火器，步枪有不错的射程和精准度，但它们的射击速度和装弹速度慢的可怜，因而在近身战中用起来非常不称手。当然，一把全自动步枪（理论上）可以瞬间把你的敌人打成筛子，但如果你操控不好它的话，你也只能拿它吓唬吓唬小孩儿。", "Rifles have terrific range and accuracy compared to other firearms, but may be slow to fire and reload, and can prove difficult to use in close quarters.  Fully automatic rifles can fire rapidly, but are harder to handle properly."),
  main_attr = "per",
}

list[#list+1] = {
  id = "shotgun",
  name = tl("霰弹枪","shotguns"),
  description = tl("霰弹枪很容易使用并可以造成大规模的破坏，但随着距离的增加其有效性和准确性会迅速下降。有些特殊弹药可以提高霰弹枪的射程，但精准度就难以恭维了。", "Shotguns are easy to shoot and can inflict massive damage, but their effectiveness and accuracy decline rapidly with range.  Slugs can be loaded into shotguns to provide greater range, though they are somewhat inaccurate."),
  main_attr = "per",
}

list[#list+1] = {
  id = "smg",
  name = tl("冲锋枪","submachine guns"),
  description = tl("使用冲锋枪和自动手枪的技能。冲锋枪介于手枪和突击步枪之间，可以快速开火，快速装弹，适合应对突发情况，不过命中率较低。", "Comprised of an automatic rifle carbine designed to fire a pistol cartridge, submachine guns can reload and fire quickly, sometimes in bursts, but they are relatively inaccurate and may be prone to mechanical failures."),
  main_attr = "per",
}


list[#list+1] = {
  id = "throw",
  name = tl("投掷","throwing"),
  description = tl("远距离投掷物体的技能。 等级越高，投掷距离和精度越高。", "Your skill in throwing objects over a distance.  Skill increases accuracy, and at higher levels, the range of a throw."),
  main_attr = "per",
}

--敏捷技能
list[#list+1] = {
  id = "dodge",
  name = tl("躲闪","dodging"),
  description = tl("躲避迎面而来威胁的技能，无论是敌人的攻击，一个触发的陷阱或落下来的岩石。 这项技能也将决定你是优雅的落地，或是一屁股砸在地板上，以及其他一些你心血来潮所做的杂技动作。","Your ability to dodge an oncoming threat, be it an enemy's attack, a triggered trap, or a falling rock.  This skill is also used in attempts to fall gracefully, and for other acrobatic feats."),
  main_attr = "dex",
}


list[#list+1] = {
  id = "defence",
  name = tl("防御","defence"),
  description = tl("防御敌人攻击，在战斗中触发格挡和招架的技能，等级高时会降低被暴击的几率。","Your skill to trigger blocking and parrying technique,  Higher levels can decrease the chance of being critial hit."),
  main_attr = "dex",
}

list[#list+1] = {
  id = "swimming",
  name = tl("游泳","swimming"),
  description = tl("在水中保持漂浮和移动的技能。 这项技能使你免于淹死，在深水中，影响你的速度和战斗力，并让你披盔戴甲游泳时也能游的轻松。", "Your ability to stay afloat and move around in bodies of water.  This skill keeps you from drowning, affects your combat effectiveness and speed in deep water, and determines the detriment of swimming with heavier gear."),
  main_attr = "dex",
}

list[#list+1] = {
  id = "driving",
  name = tl("驾驶","driving"),
  description = tl("操作和稳定住一辆飞驰中的载具的技能。等级越高，你越能控制中高速运动中的车辆，以及增加一边驾驶一边射击的命中率。", "Your skill in operating and steering a vehicle in motion.  A higher level allows greater control over vehicles at higher speeds, and reduces the penalty of shooting while driving."),
  main_attr = "dex",
}


--智力技能
list[#list+1] = {
  id = "bartering",
  name = tl("交易","bartering"),
  description = tl("讨价还价和与其他人交易的技能。等级越高越容易从交易中获利，甚至可能会有白送的便宜事。", "Your skill in bargaining, haggling, and trading with others.  Higher levels increase the odds of getting the better end of a deal, and might even see you convincing others to give you free stuff."),
  main_attr = "int",
}
list[#list+1] = {
  id = "speaking",
  name = tl("口才","speaking"),
  description = tl("跟其他人说话的技巧，比如吹嘘、 奉承、 威胁、 说服、 谎言和人际沟通的其他方面的能力。 效果与智力相关。", "Your skill in speaking to other people.  Covers ability in boasting, flattery, threats, persuasion, lies, and other facets of interpersonal communication.  Works best in conjunction with a high level of intelligence."),
  main_attr = "int",
}


list[#list+1] = {
  id = "computer",
  name = tl("计算机","computers"),
  description = tl("访问和操作计算机的技能。等级越高越能浏览更加复杂的软件系统，甚至找到其中的后门。", "Your skill in accessing and manipulating computers.  Higher levels can allow a user to navigate complex software systems and even bypass their security."),
  main_attr = "int",
}

list[#list+1] = {
  id = "construction",
  name = tl("建造","construction"),
  description = tl("建筑施工的技能。等级越高越能建造更加复杂的结构，并缩短需要的时间。", "Your general competence in building construction.  This governs the complexity of structures that can be built, and the time required to build them."),
  main_attr = "int",
}

list[#list+1] = {
  id = "cooking",
  name = tl("烹饪","cooking"),
  description = tl("把食材加工、组合，让它们变得更美味的技能。随着等级的提高，你也会学会合理混合化学物品，完成其他特别的任务。", "Your skill in combining food ingredients to make other, tastier food items.  It may also be used in certain chemical mixtures and other, more esoteric tasks."),
  main_attr = "int",
}

list[#list+1] = {
  id = "tailor",
  name = tl("裁缝","tailoring"),
  description = tl("制作维修服装、 箱包、 毛毯和其他纺织品的技能。 帮助你编织、 缝纫以及其他任何与针线有关的事儿。", "Your skill in the craft and repair of clothing, bags, blankets and other textiles.  Affects knitting, sewing, stitching, weaving, and nearly anything else involving a needle and thread."),
  main_attr = "int",
}
list[#list+1] = {
  id = "electronics",
  name = tl("电子学","electronics"),
  description = tl("制造、修复电子装备与系统的技能。 这项技能是安装和管理生化插件的重要指标。", "Your skill in dealing with electrical systems, used in the craft and repair of objects with electrical components.  This skill is an important part of installing and managing bionic implants."),
  main_attr = "int",
}

list[#list+1] = {
  id = "fabrication",
  name = tl("制作","fabrication"),
  description = tl("把原材料加工和塑造成有用东西的技能。 这项技能在各项制作中起着重要的作用。", "Your skill in working with raw materials and shaping them into useful objects.  This skill plays an important role in the crafting of many objects."),
  main_attr = "int",
}

list[#list+1] = {
  id = "firstaid",
  name = tl("急救","first aid"),
  description = tl("急救的技能。 等级越高，利用绷带和急救包等药品的效果也越好，同时也会减少并发症的发生率和医疗事故。", "Your skill in effecting emergency medical treatment.  Higher levels allow better use of medicines and items like bandages and first aid kits, and reduce the failure and complication rates of medical procedures."),
  main_attr = "int",
}

list[#list+1] = {
  id = "mechanics",
  name = tl("机械学","mechanics"),
  description = tl("操作、 维护和修理载具和其他机械系统的技能。 这项技能在制造复杂装置的时候会被用到，也影响你安装生化插件。", "Your skill in engineering, maintaining and repairing vehicles and other mechanical systems.  This skill covers the craft of items with complex parts, and plays a role in the installation of bionic equipment."),
  main_attr = "int",
}



list[#list+1] = {
  id = "survival",
  name = tl("生存","survival"),
  description = tl("在荒野生存，和制作各种基本救生物品所需的技能。 这也包括你从尸体上获取皮和肉类的能力。", "Your skill in surviving the wilderness, and in crafting various basic survival items.  This also covers your ability to skin and butcher animals for meat and hides."),
  main_attr = "int",
}


list[#list+1] = {
  id = "traps",
  name = tl("陷阱","traps"),
  description = tl("你的技能令你安全有效的创建、 设置、 查找和解除陷阱。该技能并不影响触发陷阱时的规避能力。", "Your skill in creating, setting, finding and disarming traps safely and effectively.  This skill does not affect the evasion of traps that are triggered."),
  main_attr = "int",
}






return list