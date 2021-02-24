/obj/item/pokerchip
	name = "poker chip"
	desc = "A poker chip."
	icon = 'modular_lumos/icons/obj/casinochips.dmi'
	icon_state = "none"
	w_class = WEIGHT_CLASS_TINY
	var/list/currentstack = list()
	var/choice = null
	var/value = 0
	var/chipname = null

/obj/item/pokerchip/examine()
	. = ..()
	. += "This chip is valued at [value] [value == 1 ? "credit" : "credits"]"

/obj/item/pokerchip/white
	name = "white poker chip"
	icon_state = "1chip"
	value = 1

/obj/item/pokerchip/red
	name = "red poker chip"
	icon_state = "5chip"
	value = 5

/obj/item/pokerchip/blue
	name = "blue poker chip"
	icon_state = "10chip"
	value = 10

/obj/item/pokerchip/green
	name = "green poker chip"
	icon_state = "25chip"
	value = 25

/obj/item/pokerchip/yellow
	name = "yellow poker chip"
	icon_state = "50chip"
	value = 50

/obj/item/pokerchip/black
	name = "black poker chip"
	icon_state = "100chip"
	value = 100

/obj/item/pokerchip/purple
	name = "purple poker chip"
	icon_state = "500chip"
	value = 500

/obj/item/pokerchip/pink
	name = "pink poker chip"
	icon_state = "1000chip"
	value = 1000

/obj/item/pokerchip/brown
	name = "brown poker chip"
	icon_state = "5000chip"
	value = 5000

/obj/item/pokerchip/plat
	name = "platinum chip"
	icon_state = "platchip"
	value = 38	
	
/obj/item/pokerchip/chip_pile //Recycled card code beyond these lands 
	name = "pile of chips"
	desc = "A number of cards not in a deck, customarily held in ones hand."
	icon = 'modular_lumos/icons/obj/casinochips.dmi'
	icon_state = "none"
	w_class = WEIGHT_CLASS_TINY
	var/list/currentstack = list()
	var/choice = null

/obj/item/pokerchip/chip_pile/attack_self(mob/user)
	var/list/handradial = list()
	interact(user)

	for(var/t in currentpile)
		handradial[t] = image(icon = src.icon, icon_state = "sc_[t]_[pilestyle]")

	if(usr.stat || !ishuman(usr))
		return
	var/mob/living/carbon/human/pileUser = usr
	if(!(pileUser.mobility_flags & MOBILITY_USE))
		return
	var/O = src
	var/choice = show_radial_menu(usr,src, handradial, custom_check = CALLBACK(src, .proc/check_menu, user), radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE
	var/obj/item/pokerchip/chip_pile/C = new/obj/item/pokerchip/(pileUser.loc)
	currentpile -= choice
	handradial -= choice
	C.parentpile = parentpile
	C.pilename = choice
	C.apply_pile_vars(C,O)
	C.pickup(pileUser)
	pileUser.put_in_hands(C)
	pileUser.visible_message("<span class='notice'>[pileUser] draws a chip from [pileUser.p_their()] pile.</span>", "<span class='notice'>You take the [C.pilename] from your pile.</span>")

	interact(pileUser)
	update_sprite()
	if(length(currentpile) == 1)
		var/obj/item/pokerchip/chip/N = new/obj/item/pokerchip/chip(loc)
		N.parentpile = parentpile
		N.pilename = currentpile[1]
		N.apply_pile_vars(N,O)
		qdel(src)
		N.pickup(pileUser)
		pileUser.put_in_hands(N)
		to_chat(pileUser, "<span class='notice'>You also take [currentpile[1]] and hold it.</span>")

/obj/item/pokerchip/chip_pile/attackby(obj/item/pokerchip/chip/C, mob/living/user, params)
	if(istype(C))
		if(C.parentpile == src.parentpile)
			src.currentpile += C.pilename
			user.visible_message("<span class='notice'>[user] adds a chip to [user.p_their()] pile.</span>", "<span class='notice'>You add the [C.chipname] to your pile.</span>")
			qdel(C)
			interact(user)
			update_sprite(src)
	else
		return ..()

/obj/item/pokerchip/chip_pile/apply_card_vars(obj/item/pokerchip/newobj,obj/item/pokerchip/sourceobj)
	..()
	newobj.pilestyle = sourceobj.pilestyle
	update_sprite()
	newobj.chip_hitsound = sourceobj.chip_hitsound
	newobj.chip_force = sourceobj.chip_force
	newobj.chip_throwforce = sourceobj.chip_throwforce
	newobj.chip_throw_speed = sourceobj.chip_throw_speed
	newobj.chip_throw_range = sourceobj.chip_throw_range
	newobj.chip_attack_verb = sourceobj.chip_attack_verb
	newobj.resistance_flags = sourceobj.resistance_flags

/**
  * check_menu: Checks if we are allowed to interact with a radial menu
  *
  * Arguments:
  * * user The mob interacting with a menu
  */
/obj/item/pokerchip/chip_pile/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/**
  * This proc updates the sprite for when you create a hand of cards
  */
/obj/item/pokerchip/chip_pile/proc/update_sprite()
	cut_overlays()
	var/overlay_chips = currentpile.len

	var/k = overlay_chips == 2 ? 1 : overlay_chips - 2
	for(var/i = k; i <= overlay_chips; i++)
		var/chip_overlay = image(icon=src.icon,icon_state="sc_[currentpile[i]]_[pilestyle]",pixel_x=(1-i+k)*3,pixel_y=(1-i+k)*3)
		add_overlay(chip_overlay)

/obj/item/pokerchip/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/pokerchip/))
		var/obj/item/pokerchip/C = I
		if(C.parentpile == src.parentpile)
			var/obj/item/pokerchip/chip_pile/H = new/obj/item/pokerchip/chip_pile(user.loc)
			H.currentpile += C.pilename
			H.currentpile += src.pilename
			H.parentpile = C.parentpile
			H.apply_pile_vars(H,C)
			to_chat(user, "<span class='notice'>You combine the [C.chipname] and the [src.chipname] into a pile.</span>")
			qdel(C)
			qdel(src)
			H.pickup(user)
			user.put_in_active_hand(H)

	if(istype(I, /obj/item/pokerchip/chip_pile/))
		var/obj/item/pokerchip/chip_pile/H = I
		if(H.parentpile == parentpile)
			H.currentpile += chipname
			user.visible_message("[user] adds a chip to [user.p_their()] pile.", "<span class='notice'>You add the [chipname] to your pile.</span>")
			qdel(src)
			H.interact(user)
			if(H.currentpile.len > 7)
				H.icon_state = "[pilestyle]_pile8"
			else if(H.currentpile.len > 6)
				H.icon_state = "[pilestyle]_pile7"
			else if(H.currentpile.len > 5)
				H.icon_state = "[pilestyle]_pile6"
			else if(H.currentpile.len > 4)
				H.icon_state = "[pilestyle]_pile5"
			else if(H.currentpile.len > 3)
				H.icon_state = "[pilestyle]_pile4"
			else if(H.currentpile.len > 2)
				H.icon_state = "[pilestyle]_pile3"
		else
			to_chat(user, "<span class='warning'>You can't mix chips from other piles!</span>")
	else
		return ..()

/obj/item/toy/cards/singlecard/apply_card_vars(obj/item/toy/cards/singlecard/newobj,obj/item/toy/cards/sourceobj)
	..()
	newobj.deckstyle = sourceobj.deckstyle
	newobj.icon_state = "singlecard_down_[deckstyle]" // Without this the card is invisible until flipped. It's an ugly hack, but it works.
	newobj.card_hitsound = sourceobj.card_hitsound
	newobj.hitsound = newobj.card_hitsound
	newobj.card_force = sourceobj.card_force
	newobj.force = newobj.card_force
	newobj.card_throwforce = sourceobj.card_throwforce
	newobj.throwforce = newobj.card_throwforce
	newobj.card_throw_speed = sourceobj.card_throw_speed
	newobj.throw_speed = newobj.card_throw_speed
	newobj.card_throw_range = sourceobj.card_throw_range
	newobj.throw_range = newobj.card_throw_range
	newobj.card_attack_verb = sourceobj.card_attack_verb
	newobj.attack_verb = newobj.card_attack_ver 
	