
var/global/BSACooldown = 0
var/global/floorIsLava = 0


////////////////////////////////
/proc/message_admins(var/msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span></span>"
	log_adminwarn(msg)
	for(var/client/C in admins)
		if(R_ADMIN & C.holder.rights)
			C << msg

/proc/msg_admin_attack(var/text) //Toggleable Attack Messages
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[text]</span></span>"
	log_adminwarn(rendered)
	for(var/client/C in admins)
		if(R_ADMIN & C.holder.rights)
			if(C.prefs.toggles & CHAT_ATTACKLOGS)
				var/msg = rendered
				C << msg


///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/show_player_panel(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Show Player Panel"
	set desc="Edit player (respawn, ban, heal, etc)"

	if(!M)
		usr << "You seem to be selecting a mob that doesn't exist anymore."
		return
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		usr << "Error: you are not an admin!"
		return

	checkSessionKey()
	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\admin.dm:40: var/body = "<html><head><title>Options for [M.key]</title></head>"
	var/body = {"<html><head><title>Options for [M.key]</title></head>
<body>Options panel for <b>[M]</b>"}
	// END AUTOFIX
	var/species_description
	if(M.client)

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\admin.dm:43: body += " played by <b>[M.client]</b> "
		body += {"played by <b>[M.client]</b>
			\[<A href='?src=\ref[src];editrights=show'>[M.client.holder ? M.client.holder.rank : "Player"]</A>\]"}
		// END AUTOFIX
	if(istype(M, /mob/new_player))
		body += " <B>Hasn't Entered Game</B> "
	else
		body += " \[<A href='?src=\ref[src];revive=\ref[M]'>Heal</A>\] "
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		species_description = "[H.species ? H.species.name : "<span class='danger'><b>No Species</b></span>"]"
	body += {"
		<br><br>\[
		<a href='?_src_=vars;Vars=\ref[M]'>VV</a> -
		<a href='?src=\ref[src];traitor=\ref[M]'>TP</a> -
		<a href='?src=\ref[src];rapsheet=1;rsckey=[M.ckey]'>Bans</a> -
		<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a> -
		<a href='?src=\ref[src];subtlemessage=\ref[M]'>SM</a> -
		<a href='?src=\ref[src];adminplayerobservejump=\ref[M]'>JMP</a>\] </b><br>
		<b>Mob type</b> = [M.type][species_description ? " - Species = [species_description]" : ""]<br><br>
		<A href='?src=\ref[src];boot2=\ref[M]'>Kick</A> |
		<A href='?_src_=holder;warn=[M.ckey]'>Warn</A> |
		<A href='?_src_=holder;unwarn=[M.ckey]'>UNWarn</A> |
		<A href='?src=\ref[src];newban=\ref[M]'>Ban</A> |
		<A href='?src=\ref[src];jobban2=\ref[M]'>Jobban</A> |
		<A href='?_src_=holder;appearanceban=\ref[M]'>Identity Ban</A> |
		<A href='?src=\ref[src];notes=show;mob=\ref[M]'>Notes</A>
	"}

	if(M.client)
		body += "| <A HREF='?src=\ref[src];sendtoprison=\ref[M]'>Prison</A> | "
		var/muted = M.client.prefs.muted
		body += {"<br><b>Mute: </b>
			\[<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_IC]'><font color='[(muted & MUTE_IC)?"red":"blue"]'>IC</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_OOC]'><font color='[(muted & MUTE_OOC)?"red":"blue"]'>OOC</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_PRAY]'><font color='[(muted & MUTE_PRAY)?"red":"blue"]'>PRAY</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ADMINHELP]'><font color='[(muted & MUTE_ADMINHELP)?"red":"blue"]'>ADMINHELP</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_DEADCHAT]'><font color='[(muted & MUTE_DEADCHAT)?"red":"blue"]'>DEADCHAT</font></a>\]
			(<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ALL]'><font color='[(muted & MUTE_ALL)?"red":"blue"]'>toggle all</font></a>)
		"}

	body += {"<br><br>
		<A href='?src=\ref[src];jumpto=\ref[M]'><b>Jump to</b></A> |
		<A href='?src=\ref[src];getmob=\ref[M]'>Get</A> |
		<A href='?src=\ref[src];sendmob=\ref[M]'>Send To</A>
		<br><br>
		<A href='?src=\ref[src];traitor=\ref[M]'>Traitor panel</A> |
		<A href='?src=\ref[src];narrateto=\ref[M]'>Narrate to</A> |
		<A href='?src=\ref[src];subtlemessage=\ref[M]'>Subtle message</A>
	"}

	// Mob-specific controls.
	body += M.player_panel_controls(usr)

	if (M.client)
		if(!istype(M, /mob/new_player))

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\admin.dm:90: body += "<br><br>"
			body += {"<br><br>
				<b>Transformation:</b>
				<br>"}
			// END AUTOFIX
			//Monkey
			if(ismonkey(M))
				body += "<B>Monkeyized</B> | "
			else
				body += "<A href='?src=\ref[src];monkeyone=\ref[M]'>Monkeyize</A> | "

			//Corgi
			if(iscorgi(M))
				body += "<B>Corgized</B> | "
			else
				body += "<A href='?src=\ref[src];corgione=\ref[M]'>Corgize</A> | "

			//AI / Cyborg
			if(isAI(M))
				body += "<B>Is an AI</B> "
			else if(ishuman(M))
				body += {"<A href='?src=\ref[src];makeai=\ref[M]'>Make AI</A> |
					<A href='?src=\ref[src];makerobot=\ref[M]'>Make Robot</A> |
					<A href='?src=\ref[src];makemommi=\ref[M]'>Make MoMMI</A> |
					<A href='?src=\ref[src];makealien=\ref[M]'>Make Alien</A> |
					<A href='?src=\ref[src];makeslime=\ref[M]'>Make slime</A> |
					<A href='?src=\ref[src];makecluwne=\ref[M]'>Make Cluwne</A> |
				"}

			//Simple Animals
			if(isanimal(M))
				body += "<A href='?src=\ref[src];makeanimal=\ref[M]'>Re-Animalize</A> | "
			else
				body += "<A href='?src=\ref[src];makeanimal=\ref[M]'>Animalize</A> | "

			// DNA2 - Admin Hax
			if(iscarbon(M) && !isbrain(M) && !isalien(M))
				body += "<br><br>"
				body += "<b>DNA Blocks:</b><br><table border='0'><tr><th>&nbsp;</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th>"
				var/bname
				for(var/block=1;block<=DNA_SE_LENGTH;block++)
					if(((block-1)%5)==0)
						body += "</tr><tr><th>[block-1]</th>"
					bname = assigned_blocks[block]
					body += "<td>"
					if(bname)
						var/bstate=M.dna.GetSEState(block)
						var/bcolor="[(bstate)?"#006600":"#ff0000"]"
						body += "<A href='?src=\ref[src];togmutate=\ref[M];block=[block]' style='color:[bcolor];'>[bname]</A><sub>[block]</sub>"
					else
						body += "[block]"
					body+="</td>"
				body += "</tr></table>"

			// Law Admin Hax
			if(issilicon(M) && M:laws)
				body += "<br><br>"
				body += "<b>Laws:</b><br />"
				var/datum/ai_laws/L = M:laws
				body += L.display_admin_tools(M)
				body += "<br /><a href='?src=\ref[src];mob=\ref[M];add_law=1'>Add Law</a>"
				body += " | <a href='?src=\ref[src];mob=\ref[M];clear_laws=1'>Clear Laws</a>"
				body += " | <a href='?src=\ref[src];mob=\ref[M];reset_laws=1'>Reset Lawset</a>"
				body += "<br /><a href='?src=\ref[src];mob=\ref[M];announce_laws=1'><b>Send Laws</b></a> - User is not notified of changes until this button pushed!<br />"

			body += {"<br><br>
				<b>Rudimentary transformation:</b><font size=2><br>These transformations only create a new mob type and copy stuff over. They do not take into account MMIs and similar mob-specific things. The buttons in 'Transformations' are preferred, when possible.</font><br>
				<A href='?src=\ref[src];simplemake=observer;mob=\ref[M]'>Observer</A> |
				\[ Alien: <A href='?src=\ref[src];simplemake=drone;mob=\ref[M]'>Drone</A>,
				<A href='?src=\ref[src];simplemake=hunter;mob=\ref[M]'>Hunter</A>,
				<A href='?src=\ref[src];simplemake=queen;mob=\ref[M]'>Queen</A>,
				<A href='?src=\ref[src];simplemake=sentinel;mob=\ref[M]'>Sentinel</A>,
				<A href='?src=\ref[src];simplemake=larva;mob=\ref[M]'>Larva</A> \]
				<A href='?src=\ref[src];simplemake=human;mob=\ref[M]'>Human</A>
				\[ slime: <A href='?src=\ref[src];simplemake=slime;mob=\ref[M]'>Baby</A>,
				<A href='?src=\ref[src];simplemake=adultslime;mob=\ref[M]'>Adult</A> \]
				<A href='?src=\ref[src];simplemake=monkey;mob=\ref[M]'>Monkey</A> |
				<A href='?src=\ref[src];simplemake=robot;mob=\ref[M]'>Cyborg</A> |
				<A href='?src=\ref[src];simplemake=cat;mob=\ref[M]'>Cat</A> |
				<A href='?src=\ref[src];simplemake=runtime;mob=\ref[M]'>Runtime</A> |
				<A href='?src=\ref[src];simplemake=corgi;mob=\ref[M]'>Corgi</A> |
				<A href='?src=\ref[src];simplemake=ian;mob=\ref[M]'>Ian</A> |
				<A href='?src=\ref[src];simplemake=crab;mob=\ref[M]'>Crab</A> |
				<A href='?src=\ref[src];simplemake=coffee;mob=\ref[M]'>Coffee</A> |
				\[ Construct: <A href='?src=\ref[src];simplemake=constructarmoured;mob=\ref[M]'>Armoured</A> ,
				<A href='?src=\ref[src];simplemake=constructbuilder;mob=\ref[M]'>Builder</A> ,
				<A href='?src=\ref[src];simplemake=constructwraith;mob=\ref[M]'>Wraith</A> \]
				<A href='?src=\ref[src];simplemake=shade;mob=\ref[M]'>Shade</A>
				<br>
			"}

	if (M.client)
		body += {"<br><br>
			<b>Other actions:</b>
			<br>
			<A href='?src=\ref[src];forcespeech=\ref[M]'>Forcesay</A> |
			<A href='?src=\ref[src];tdome1=\ref[M]'>Thunderdome Green</A> |
			<A href='?src=\ref[src];tdome2=\ref[M]'>Thunderdome Red</A> |
			<A href='?src=\ref[src];tdomeadmin=\ref[M]'>Thunderdome Admin</A> |
			<A href='?src=\ref[src];tdomeobserve=\ref[M]'>Thunderdome Observer</A> |
		"}

	body += {"<br>
		</body></html>
	"}

	usr << browse(body, "window=adminplayeropts-\ref[M];size=550x515")
	feedback_add_details("admin_verb","SPP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/player_info/var/author // admin who authored the information
/datum/player_info/var/rank //rank of admin who made the notes
/datum/player_info/var/content // text content of the information
/datum/player_info/var/timestamp // Because this is bloody annoying

#define PLAYER_NOTES_ENTRIES_PER_PAGE 50
/datum/admins/proc/PlayerNotes()
	set category = "Admin"
	set name = "Player Notes"
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		usr << "Error: you are not an admin!"
		return
	PlayerNotesPage(1)

/datum/admins/proc/checkCID()
	set category = "Admin"
	set name = "Lookup bans on Computer ID"
	if(!usr)
		return
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		usr << "Error: you are not an admin!"
		return
	checkSessionKey()
	var/cid = input("Type computer ID", "CID", 0)
	usr << link(getVGPanel("rapsheet",admin=1,query=list("cid"=cid)))
	//usr << link("[config.vgws_base_url]/index.php/rapsheet/?s=[sessKey]&cid=[cid]")
	return

/datum/admins/proc/checkCKEY()
	set category = "Admin"
	set name = "Lookup bans on CKEY"
	if(!usr)
		return
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		usr << "Error: you are not an admin!"
		return
	checkSessionKey()
	var/ckey = lowertext(input("Type player ckey", "ckey", null) as text | null)
	usr << link(getVGPanel("rapsheet",admin=1,query=list("ckey"=ckey)))
	//usr << link("[config.vgws_base_url]/index.php/rapsheet/?s=[sessKey]&ckey=[ckey]")
	return

/datum/admins/proc/PlayerNotesPage(page)
	var/dat = "<B>Player notes</B><HR>"
	var/savefile/S=new("data/player_notes.sav")
	var/list/note_keys
	S >> note_keys
	if(!note_keys)
		dat += "No notes found."
	else
		dat += "<table>"
		note_keys = sortList(note_keys)

		// Display the notes on the current page
		var/number_pages = note_keys.len / PLAYER_NOTES_ENTRIES_PER_PAGE
		// Emulate ceil(why does BYOND not have ceil)
		if(number_pages != round(number_pages))
			number_pages = round(number_pages) + 1
		var/page_index = page - 1
		if(page_index < 0 || page_index >= number_pages)
			return

		var/lower_bound = page_index * PLAYER_NOTES_ENTRIES_PER_PAGE + 1
		var/upper_bound = (page_index + 1) * PLAYER_NOTES_ENTRIES_PER_PAGE
		upper_bound = min(upper_bound, note_keys.len)
		for(var/index = lower_bound, index <= upper_bound, index++)
			var/t = note_keys[index]
			dat += "<tr><td><a href='?src=\ref[src];notes=show;ckey=[t]'>[t]</a></td></tr>"

		dat += "</table><br>"

		// Display a footer to select different pages
		for(var/index = 1, index <= number_pages, index++)
			if(index == page)
				dat += "<b>"
			dat += "<a href='?src=\ref[src];notes=list;index=[index]'>[index]</a> "
			if(index == page)
				dat += "</b>"

	usr << browse(dat, "window=player_notes;size=400x400")


/datum/admins/proc/player_has_info(var/key as text)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos || !infos.len) return 0
	else return 1


/datum/admins/proc/show_player_info(var/key as text)
	set category = "Admin"
	set name = "Show Player Info"
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		usr << "Error: you are not an admin!"
		return

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\admin.dm:247: var/dat = "<html><head><title>Info on [key]</title></head>"
	var/dat = {"<html><head><title>Info on [key]</title></head>
<body>"}
	// END AUTOFIX
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos)
		dat += "No information found on the given key.<br>"
	else
		var/update_file = 0
		var/i = 0
		for(var/datum/player_info/I in infos)
			i += 1
			if(!I.timestamp)
				I.timestamp = "Pre-4/3/2012"
				update_file = 1
			if(!I.rank)
				I.rank = "N/A"
				update_file = 1
			dat += "<font color=#008800>[I.content]</font> <i>by [I.author] ([I.rank])</i> on <i><font color=blue>[I.timestamp]</i></font> "
			if(I.author == usr.key)
				dat += "<A href='?src=\ref[src];remove_player_info=[key];remove_index=[i]'>Remove</A>"
			dat += "<br><br>"
		if(update_file) info << infos


	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\admin.dm:265: dat += "<br>"
	dat += {"<br>
		<A href='?src=\ref[src];add_player_info=[key]'>Add Comment</A><br>
		</body></html>"}
	// END AUTOFIX
	usr << browse(dat, "window=adminplayerinfo;size=480x480")



/datum/admins/proc/access_news_network() //MARKER
	set category = "Fun"
	set name = "Access Newscaster Network"
	set desc = "Allows you to view, add and edit news feeds."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		usr << "Error: you are not an admin!"
		return
	var/dat
	dat = text("<HEAD><TITLE>Admin Newscaster</TITLE></HEAD><H3>Admin Newscaster Unit</H3>")

	switch(admincaster_screen)
		if(0)
			dat += {"Welcome to the admin newscaster.<BR> Here you can add, edit and censor every newspiece on the network.
				<BR>Feed channels and stories entered through here will be uneditable and handled as official news by the rest of the units.
				<BR>Note that this panel allows full freedom over the news network, there are no constrictions except the few basic ones. Don't break things!</FONT>
			"}
			if(news_network.wanted_issue)
				dat+= "<HR><A href='?src=\ref[src];ac_view_wanted=1'>Read Wanted Issue</A>"

			dat+= {"<HR><BR><A href='?src=\ref[src];ac_create_channel=1'>Create Feed Channel</A>
				<BR><A href='?src=\ref[src];ac_view=1'>View Feed Channels</A>
				<BR><A href='?src=\ref[src];ac_create_feed_story=1'>Submit new Feed story</A>
				<BR><BR><A href='?src=\ref[usr];mach_close=newscaster_main'>Exit</A>
			"}

			var/wanted_already = 0
			if(news_network.wanted_issue)
				wanted_already = 1

			dat+={"<HR><B>Feed Security functions:</B><BR>
				<BR><A href='?src=\ref[src];ac_menu_wanted=1'>[(wanted_already) ? ("Manage") : ("Publish")] \"Wanted\" Issue</A>
				<BR><A href='?src=\ref[src];ac_menu_censor_story=1'>Censor Feed Stories</A>
				<BR><A href='?src=\ref[src];ac_menu_censor_channel=1'>Mark Feed Channel with Nanotrasen D-Notice (disables and locks the channel.</A>
				<BR><HR><A href='?src=\ref[src];ac_set_signature=1'>The newscaster recognises you as:<BR> <FONT COLOR='green'>[src.admincaster_signature]</FONT></A>
			"}
		if(1)
			dat+= "Station Feed Channels<HR>"
			if( isemptylist(news_network.network_channels) )
				dat+="<I>No active channels found...</I>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					if(CHANNEL.is_admin_channel)
						dat+="<B><FONT style='BACKGROUND-COLOR: LightGreen'><A href='?src=\ref[src];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A></FONT></B><BR>"
					else
						dat+="<B><A href='?src=\ref[src];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ()]<BR></B>"
			dat+={"<BR><HR><A href='?src=\ref[src];ac_refresh=1'>Refresh</A>
				<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Back</A>
			"}

		if(2)
			dat+={"
				Creating new Feed Channel...
				<HR><B><A href='?src=\ref[src];ac_set_channel_name=1'>Channel Name</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>
				<B><A href='?src=\ref[src];ac_set_signature=1'>Channel Author</A>:</B> <FONT COLOR='green'>[src.admincaster_signature]</FONT><BR>
				<B><A href='?src=\ref[src];ac_set_channel_lock=1'>Will Accept Public Feeds</A>:</B> [(src.admincaster_feed_channel.locked) ? ("NO") : ("YES")]<BR><BR>
				<BR><A href='?src=\ref[src];ac_submit_new_channel=1'>Submit</A><BR><BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A><BR>
			"}
		if(3)
			dat+={"
				Creating new Feed Message...
				<HR><B><A href='?src=\ref[src];ac_set_channel_receiving=1'>Receiving Channel</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>" //MARK
				<B>Message Author:</B> <FONT COLOR='green'>[src.admincaster_signature]</FONT><BR>
				<B><A href='?src=\ref[src];ac_set_new_message=1'>Message Body</A>:</B> [src.admincaster_feed_message.body] <BR>
				<BR><A href='?src=\ref[src];ac_submit_new_message=1'>Submit</A><BR><BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A><BR>
			"}
		if(4)
			dat+={"
					Feed story successfully submitted to [src.admincaster_feed_channel.channel_name].<BR><BR>
					<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
				"}
		if(5)
			dat+={"
				Feed Channel [src.admincaster_feed_channel.channel_name] created successfully.<BR><BR>
				<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(6)
			dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed story to Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_channel.channel_name=="")
				dat+="<FONT COLOR='maroon'>�Invalid receiving channel name.</FONT><BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>�Invalid message body.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[3]'>Return</A><BR>"
		if(7)
			dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed Channel to Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_channel.channel_name =="" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>�Invalid channel name.</FONT><BR>"
			var/check = 0
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == src.admincaster_feed_channel.channel_name)
					check = 1
					break
			if(check)
				dat+="<FONT COLOR='maroon'>�Channel name already in use.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[2]'>Return</A><BR>"
		if(9)
			dat+="<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT>\]</FONT><HR>"
			if(src.admincaster_feed_channel.censored)
				dat+={"
					<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>
					No further feed story additions are allowed while the D-Notice is in effect.</FONT><BR><BR>
				"}
			else
				if( isemptylist(src.admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					var/i = 0
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						i++
						dat+="-[MESSAGE.body] <BR>"
						if(MESSAGE.img)
							usr << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
							dat+="<img src='tmp_photo[i].png' width = '180'><BR><BR>"
						dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"
			dat+={"
				<BR><HR><A href='?src=\ref[src];ac_refresh=1'>Refresh</A>
				<BR><A href='?src=\ref[src];ac_setScreen=[1]'>Back</A>
			"}
		if(10)
			dat+={"
				<B>Nanotrasen Feed Censorship Tool</B><BR>
				<FONT SIZE=1>NOTE: Due to the nature of news Feeds, total deletion of a Feed Story is not possible.<BR>
				Keep in mind that users attempting to view a censored feed will instead see the \[REDACTED\] tag above it.</FONT>
				<HR>Select Feed channel to get Stories from:<BR>
			"}
			if(isemptylist(news_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					dat+="<A href='?src=\ref[src];ac_pick_censor_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ()]<BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A>"
		if(11)
			dat+={"
				<B>Nanotrasen D-Notice Handler</B><HR>
				<FONT SIZE=1>A D-Notice is to be bestowed upon the channel if the handling Authority deems it as harmful for the station's
				morale, integrity or disciplinary behaviour. A D-Notice will render a channel unable to be updated by anyone, without deleting any feed
				stories it might contain at the time. You can lift a D-Notice if you have the required access at any time.</FONT><HR>
			"}
			if(isemptylist(news_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					dat+="<A href='?src=\ref[src];ac_pick_d_notice=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ()]<BR>"

			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Back</A>"
		if(12)
			dat+={"
				<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT> \]</FONT><BR>
				<FONT SIZE=2><A href='?src=\ref[src];ac_censor_channel_author=\ref[src.admincaster_feed_channel]'>[(src.admincaster_feed_channel.author=="\[REDACTED\]") ? ("Undo Author censorship") : ("Censor channel Author")]</A></FONT><HR>
			"}
			if( isemptylist(src.admincaster_feed_channel.messages) )
				dat+="<I>No feed messages found in channel...</I><BR>"
			else
				for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
					dat+={"
						-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>
						<FONT SIZE=2><A href='?src=\ref[src];ac_censor_channel_story_body=\ref[MESSAGE]'>[(MESSAGE.body == "\[REDACTED\]") ? ("Undo story censorship") : ("Censor story")]</A>  -  <A href='?src=\ref[src];ac_censor_channel_story_author=\ref[MESSAGE]'>[(MESSAGE.author == "\[REDACTED\]") ? ("Undo Author Censorship") : ("Censor message Author")]</A></FONT><BR>
					"}
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[10]'>Back</A>"
		if(13)
			dat+={"
				<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT> \]</FONT><BR>
				Channel messages listed below. If you deem them dangerous to the station, you can <A href='?src=\ref[src];ac_toggle_d_notice=\ref[src.admincaster_feed_channel]'>Bestow a D-Notice upon the channel</A>.<HR>
			"}
			if(src.admincaster_feed_channel.censored)
				dat+={"
					<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>
					No further feed story additions are allowed while the D-Notice is in effect.</FONT><BR><BR>
				"}
			else
				if( isemptylist(src.admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						dat+="-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"

			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[11]'>Back</A>"
		if(14)
			dat+="<B>Wanted Issue Handler:</B>"
			var/wanted_already = 0
			var/end_param = 1
			if(news_network.wanted_issue)
				wanted_already = 1
				end_param = 2
			if(wanted_already)
				dat+="<FONT SIZE=2><BR><I>A wanted issue is already in Feed Circulation. You can edit or cancel it below.</FONT></I>"
			dat+={"
				<HR>
				<A href='?src=\ref[src];ac_set_wanted_name=1'>Criminal Name</A>: [src.admincaster_feed_message.author] <BR>
				<A href='?src=\ref[src];ac_set_wanted_desc=1'>Description</A>: [src.admincaster_feed_message.body] <BR>
			"}
			if(wanted_already)
				dat+="<B>Wanted Issue created by:</B><FONT COLOR='green'> [news_network.wanted_issue.backup_author]</FONT><BR>"
			else
				dat+="<B>Wanted Issue will be created under prosecutor:</B><FONT COLOR='green'> [src.admincaster_signature]</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
			if(wanted_already)
				dat+="<BR><A href='?src=\ref[src];ac_cancel_wanted=1'>Take down Issue</A>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A>"
		if(15)
			dat+={"
				<FONT COLOR='green'>Wanted issue for [src.admincaster_feed_message.author] is now in Network Circulation.</FONT><BR><BR>
				<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(16)
			dat+="<B><FONT COLOR='maroon'>ERROR: Wanted Issue rejected by Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_message.author =="" || src.admincaster_feed_message.author == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>�Invalid name for person wanted.</FONT><BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>�Invalid description.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>"
		if(17)
			dat+={"
				<B>Wanted Issue successfully deleted from Circulation</B><BR>
				<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(18)
			dat+={"
				<B><FONT COLOR ='maroon'>-- STATIONWIDE WANTED ISSUE --</B></FONT><BR><FONT SIZE=2>\[Submitted by: <FONT COLOR='green'>[news_network.wanted_issue.backup_author]</FONT>\]</FONT><HR>
				<B>Criminal</B>: [news_network.wanted_issue.author]<BR>
				<B>Description</B>: [news_network.wanted_issue.body]<BR>
				<B>Photo:</B>:
			"}
			if(news_network.wanted_issue.img)
				usr << browse_rsc(news_network.wanted_issue.img, "tmp_photow.png")
				dat+="<BR><img src='tmp_photow.png' width = '180'>"
			else
				dat+="None"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Back</A><BR>"
		if(19)
			dat+={"
				<FONT COLOR='green'>Wanted issue for [src.admincaster_feed_message.author] successfully edited.</FONT><BR><BR>
				<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		else
			dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

	//world << "Channelname: [src.admincaster_feed_channel.channel_name] [src.admincaster_feed_channel.author]"
	//world << "Msg: [src.admincaster_feed_message.author] [src.admincaster_feed_message.body]"
	usr << browse(dat, "window=admincaster_main;size=400x600")
	onclose(usr, "admincaster_main")



/datum/admins/proc/Jobbans()
	if(!check_rights(R_BAN))	return

	var/dat = "<B>Job Bans!</B><HR><table>"
	for(var/t in jobban_keylist)
		var/r = t
		if( findtext(r,"##") )
			r = copytext( r, 1, findtext(r,"##") )//removes the description
		dat += text("<tr><td>[t] (<A href='?src=\ref[src];removejobban=[r]'>unban</A>)</td></tr>")
	dat += "</table>"
	usr << browse(dat, "window=ban;size=400x400")

/datum/admins/proc/Game()
	if(!check_rights(0))	return

	var/dat = {"
		<center><B>Game Panel</B></center><hr>\n
		<A href='?src=\ref[src];c_mode=1'>Change Game Mode</A><br>
		"}
	if(master_mode == "secret")
		dat += "<A href='?src=\ref[src];f_secret=1'>(Force Secret Mode)</A><br>"

	dat += {"
		<hr />
		<ul>
			<li>
				<a href="?src=\ref[src];set_base_laws=ai"><b>Default Cyborg/AI Laws:</b>[base_law_type]</a>
			</li>
			<li>
				<a href="?src=\ref[src];set_base_laws=mommi"><b>Default MoMMI Laws:</b>[mommi_base_law_type]</a>
			</li>
		</ul>
		<hr />
		<A href='?src=\ref[src];create_object=1'>Create Object</A><br>
		<A href='?src=\ref[src];quick_create_object=1'>Quick Create Object</A><br>
		<A href='?src=\ref[src];create_turf=1'>Create Turf</A><br>
		<A href='?src=\ref[src];create_mob=1'>Create Mob</A><br>
		<hr />
		<A href='?src=\ref[src];vsc=airflow'>Edit ZAS Settings</A><br>
		<A href='?src=\ref[src];vsc=default'>Choose a default ZAS setting</A><br>
		"}

	usr << browse(dat, "window=admin2;size=280x370")
	return

/datum/admins/proc/Secrets()
	if(!check_rights(0))	return

	var/dat = "<B>The first rule of adminbuse is: you don't talk about the adminbuse.</B><HR>"

	if(check_rights(R_FUN,0) || check_rights(R_ADMINBUS,0))
		dat += {"
			<B>Fourth-Wall Demolition</B><BR>
			<BR>
			"}
	if(check_rights(R_ADMINBUS,0))
		dat += {"
			<A href='?src=\ref[src];secretsfun=spawnadminbus'>Spawn an Adminbus</A><BR>
			"}
	if(check_rights(R_FUN,0))
		dat += {"
			<A href='?src=\ref[src];secretsfun=spawnselfdummy'>Spawn yourself as a Test Dummy</A><BR>
			<BR>
			"}

	if(check_rights(R_ADMIN,0))
		dat += {"
			<B>Admin Secrets</B><BR>
			<BR>
			<A href='?src=\ref[src];secretsadmin=clear_bombs'>Remove all bombs currently in existence</A><BR>
			<A href='?src=\ref[src];secretsadmin=list_bombers'>Bombing List</A><BR>
			<A href='?src=\ref[src];secretsadmin=check_antagonist'>Show current traitors and objectives</A><BR>
			<A href='?src=\ref[src];secretsadmin=list_signalers'>Show last [length(lastsignalers)] signalers</A><BR>
			<A href='?src=\ref[src];secretsadmin=list_lawchanges'>Show last [length(lawchanges)] law changes</A><BR>
			<A href='?src=\ref[src];secretsadmin=showailaws'>Show AI Laws</A><BR>
			<A href='?src=\ref[src];secretsadmin=showgm'>Show Game Mode</A><BR>
			<A href='?src=\ref[src];secretsadmin=manifest'>Show Crew Manifest</A><BR>
			<A href='?src=\ref[src];secretsadmin=DNA'>List DNA (Blood)</A><BR>
			<A href='?src=\ref[src];secretsadmin=fingerprints'>List Fingerprints</A><BR><BR>
			<BR>
			"}

	if(check_rights(R_FUN,0))
		dat += {"
			<B>'Random' Events</B><BR>
			<BR>
			<A href='?src=\ref[src];secretsfun=gravity'>Toggle station artificial gravity</A><BR>
			<A href='?src=\ref[src];secretsfun=wave'>Spawn a wave of meteors (aka lagocolyptic shower)</A><BR>
			<A href='?src=\ref[src];secretsfun=gravanomalies'>Spawn a gravitational anomaly (aka lagitational anomolag)</A><BR>
			<A href='?src=\ref[src];secretsfun=timeanomalies'>Spawn wormholes</A><BR>
			<A href='?src=\ref[src];secretsfun=goblob'>Spawn blob</A><BR>
			<A href='?src=\ref[src];secretsfun=aliens'>Trigger an Alien infestation</A><BR>
			<A href='?src=\ref[src];secretsfun=alien_silent'>Spawn an Alien silently</A><BR>
			<A href='?src=\ref[src];secretsfun=spiders'>Trigger a Spider infestation</A><BR>
			<A href='?src=\ref[src];secretsfun=spaceninja'>Send in a space ninja</A><BR>
			<A href='?src=\ref[src];secretsfun=striketeam'>Send in a strike team</A><BR>
			<A href='?src=\ref[src];secretsfun=carp'>Trigger a Carp migration</A><BR>
			<A href='?src=\ref[src];secretsfun=radiation'>Irradiate the station</A><BR>
			<A href='?src=\ref[src];secretsfun=prison_break'>Trigger a Prison Break</A><BR>
			<A href='?src=\ref[src];secretsfun=virus'>Trigger a Virus Outbreak</A><BR>
			<A href='?src=\ref[src];secretsfun=immovable'>Spawn an Immovable Rod</A><BR>
			<A href='?src=\ref[src];secretsfun=lightsout'>Toggle a "lights out" event</A><BR>
			<A href='?src=\ref[src];secretsfun=ionstorm'>Spawn an Ion Storm</A><BR>
			<A href='?src=\ref[src];secretsfun=spacevines'>Spawn Space-Vines</A><BR>
			<A href='?src=\ref[src];secretsfun=comms_blackout'>Trigger a communication blackout</A><BR>
			<A href='?src=\ref[src];secretsfun=pda_spam'>Trigger a wave of PDA spams</A><BR>
			<BR>
			<B>Fun Secrets</B><BR>
			<BR>
			<A href='?src=\ref[src];secretsfun=sec_clothes'>Remove 'internal' clothing</A><BR>
			<A href='?src=\ref[src];secretsfun=sec_all_clothes'>Remove ALL clothing</A><BR>
			<A href='?src=\ref[src];secretsfun=monkey'>Turn all humans into monkeys</A><BR>
			<A href='?src=\ref[src];secretsfun=sec_classic1'>Remove firesuits, grilles, and pods</A><BR>
			<A href='?src=\ref[src];secretsfun=power'>Make all areas powered</A><BR>
			<A href='?src=\ref[src];secretsfun=unpower'>Make all areas unpowered</A><BR>
			<A href='?src=\ref[src];secretsfun=quickpower'>Power all SMES</A><BR>
			<A href='?src=\ref[src];secretsfun=toggleprisonstatus'>Toggle Prison Shuttle Status(Use with S/R)</A><BR>
			<A href='?src=\ref[src];secretsfun=activateprison'>Send Prison Shuttle</A><BR>
			<A href='?src=\ref[src];secretsfun=deactivateprison'>Return Prison Shuttle</A><BR>
			<A href='?src=\ref[src];secretsfun=prisonwarp'>Warp all Players to Prison</A><BR>
			<A href='?src=\ref[src];secretsfun=tripleAI'>Triple AI mode (needs to be used in the lobby)</A><BR>
			<A href='?src=\ref[src];secretsfun=traitor_all'>Everyone is the traitor</A><BR>
			<A href='?src=\ref[src];secretsfun=onlyone'>There can only be one!</A><BR>
			<A href='?src=\ref[src];secretsfun=flicklights'>Ghost Mode</A><BR>
			<A href='?src=\ref[src];secretsfun=retardify'>Make all players retarded</A><BR>
			<A href='?src=\ref[src];secretsfun=fakeguns'>Make all items look like guns</A><BR>
			<A href='?src=\ref[src];secretsfun=schoolgirl'>Japanese Animes Mode</A><BR>
			<A href='?src=\ref[src];secretsfun=eagles'>Egalitarian Station Mode</A><BR>
			<A href='?src=\ref[src];secretsfun=moveadminshuttle'>Move Administration Shuttle</A><BR>
			<A href='?src=\ref[src];secretsfun=moveferry'>Move Ferry</A><BR>
			<A href='?src=\ref[src];secretsfun=movealienship'>Move Alien Dinghy</A><BR>
			<A href='?src=\ref[src];secretsfun=moveminingshuttle'>Move Mining Shuttle</A><BR>
			<A href='?src=\ref[src];secretsfun=blackout'>Break all lights</A><BR>
			<A href='?src=\ref[src];secretsfun=whiteout'>Fix all lights</A><BR>
			<A href='?src=\ref[src];secretsfun=floorlava'>The floor is lava! (DANGEROUS: extremely lame)</A><BR>
			<A href='?src=\ref[src];secretsfun=togglenarsie'>Toggle Nar-Sie's behaviour</A><BR>
			<A href='?src=\ref[src];secretsfun=fakealerts'>Trigger a fake alert</A><BR>
			<A href='?src=\ref[src];secretsfun=fakebooms'>Adds in some Micheal Bay to the shift without major destruction</A><BR>
			<BR>
			<B>Final Solutions</B><BR>
			<I>(Warning, these will end the round!)</I><BR>
			<BR>
			<A href='?src=\ref[src];secretsfun=hellonearth'>Summon Nar-Sie</A><BR>
			<A href='?src=\ref[src];secretsfun=supermattercascade'>Start a Supermatter Cascade</A><BR>
			"}

	if(check_rights(R_SERVER,0))

		dat += {"
			<BR>
			<B>Server</B><BR>
			<BR>
			<A href='?src=\ref[src];secretsfun=togglebombcap'>Toggle bomb cap</A><BR>"}

	dat += "<BR>"

	if(check_rights(R_DEBUG,0))
		dat += {"
			<B>Security Level Elevated</B><BR>
			<BR>
			<A href='?src=\ref[src];secretscoder=maint_access_engiebrig'>Change all maintenance doors to engie/brig access only</A><BR>
			<A href='?src=\ref[src];secretscoder=maint_access_brig'>Change all maintenance doors to brig access only</A><BR>
			<A href='?src=\ref[src];secretscoder=infinite_sec'>Remove cap on security officers</A><BR>
			<a href='?src=\ref[src];secretscoder=virus_custom'>Custom Virus Outbreak</a><BR>
			<BR>
			<B>Coder Secrets</B><BR>
			<BR>
			<A href='?src=\ref[src];secretsadmin=list_job_debug'>Show Job Debug</A><BR>
			<A href='?src=\ref[src];secretscoder=spawn_objects'>Admin Log</A><BR>
			<BR>
			"}

	usr << browse(dat, "window=secrets")
	return



/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


/datum/admins/proc/restart()
	set category = "Server"
	set name = "Restart"
	set desc="Restarts the world"
	if (!usr.client.holder)
		return
	var/confirm = alert("Restart the game world?", "Restart", "Yes", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Yes")
		world << "\red <b>Restarting world!</b> \blue Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]!"
		log_admin("[key_name(usr)] initiated a reboot.")

		feedback_set_details("end_error","admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]")
		feedback_add_details("admin_verb","R") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		if(blackbox)
			blackbox.save_all_data_to_sql()

		CallHook("Reboot",list())

		if (watchdog.waiting)
			world << "\blue <B>Server will shut down for an automatic update in a few seconds.</B>"
			watchdog.signal_ready()
			return

		sleep(50)
		world.Reboot()


/datum/admins/proc/announce()
	set category = "Special Verbs"
	set name = "Announce"
	set desc="Announce your desires to the world"
	if(!check_rights(0))	return

	var/message = input("Global message to send:", "Admin Announce", null, null)  as message
	if(message)
		if(!check_rights(R_SERVER,0))
			message = adminscrub(message,500)
		world << "\blue <b>[usr.client.holder.fakekey ? "Administrator" : usr.key] Announces:</b>\n \t [message]"
		log_admin("Announce: [key_name(usr)] : [message]")
	feedback_add_details("admin_verb","A") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleooc()
	set category = "Server"
	set desc="Globally Toggles OOC"
	set name="Toggle OOC"
	ooc_allowed = !( ooc_allowed )
	if (ooc_allowed)
		world << "<B>The OOC channel has been globally enabled!</B>"
	else
		world << "<B>The OOC channel has been globally disabled!</B>"
	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled OOC.", 1)
	feedback_add_details("admin_verb","TOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleoocdead()
	set category = "Server"
	set desc="Toggle dis bitch"
	set name="Toggle Dead OOC"
	dooc_allowed = !( dooc_allowed )

	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.", 1)
	feedback_add_details("admin_verb","TDOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggletraitorscaling()
	set category = "Server"
	set desc="Toggle traitor scaling"
	set name="Toggle Traitor Scaling"
	traitor_scaling = !traitor_scaling
	log_admin("[key_name(usr)] toggled Traitor Scaling to [traitor_scaling].")
	message_admins("[key_name_admin(usr)] toggled Traitor Scaling [traitor_scaling ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TTS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/startnow()
	set category = "Server"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(!ticker)
		alert("Unable to start the game as it is not set up.")
		return
	if(ticker.current_state == GAME_STATE_PREGAME)
		ticker.current_state = GAME_STATE_SETTING_UP
		log_admin("[usr.key] has started the game.")
		message_admins("<font color='blue'>[usr.key] has started the game.</font>")
		feedback_add_details("admin_verb","SN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return 1
	else
		usr << "<font color='red'>Error: Start Now: Game has already started.</font>"
		return 0

/datum/admins/proc/toggleenter()
	set category = "Server"
	set desc="People can't enter"
	set name="Toggle Entering"
	enter_allowed = !( enter_allowed )
	if (!( enter_allowed ))
		world << "<B>New players may no longer enter the game.</B>"
	else
		world << "<B>New players may now enter the game.</B>"
	log_admin("[key_name(usr)] toggled new player game entering.")
	message_admins("\blue [key_name_admin(usr)] toggled new player game entering.", 1)
	world.update_status()
	feedback_add_details("admin_verb","TE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleAI()
	set category = "Server"
	set desc="People can't be AI"
	set name="Toggle AI"
	config.allow_ai = !( config.allow_ai )
	if (!( config.allow_ai ))
		world << "<B>The AI job is no longer chooseable.</B>"
	else
		world << "<B>The AI job is chooseable now.</B>"
	log_admin("[key_name(usr)] toggled AI allowed.")
	world.update_status()
	feedback_add_details("admin_verb","TAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleaban()
	set category = "Server"
	set desc="Respawn basically"
	set name="Toggle Respawn"
	abandon_allowed = !( abandon_allowed )
	if (abandon_allowed)
		world << "<B>You may now respawn.</B>"
	else
		world << "<B>You may no longer respawn :(</B>"
	message_admins("\blue [key_name_admin(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].", 1)
	log_admin("[key_name(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].")
	world.update_status()
	feedback_add_details("admin_verb","TR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggle_aliens()
	set category = "Server"
	set desc="Toggle alien mobs"
	set name="Toggle Aliens"
	aliens_allowed = !aliens_allowed
	log_admin("[key_name(usr)] toggled Aliens to [aliens_allowed].")
	message_admins("[key_name_admin(usr)] toggled Aliens [aliens_allowed ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggle_space_ninja()
	set category = "Server"
	set desc="Toggle space ninjas spawning."
	set name="Toggle Space Ninjas"
	toggle_space_ninja = !toggle_space_ninja
	log_admin("[key_name(usr)] toggled Space Ninjas to [toggle_space_ninja].")
	message_admins("[key_name_admin(usr)] toggled Space Ninjas [toggle_space_ninja ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TSN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
#define LOBBY_TICKING_STOPPED 0
#define LOBBY_TICKING_RESTARTED 2
/datum/admins/proc/delay()
	set category = "Server"
	set desc="Delay the game start/end"
	set name="Delay"

	if(!check_rights(R_ADMIN))	return
	if (!ticker || ticker.current_state != GAME_STATE_PREGAME)
		if(ticker.delay_end == 2)
			world << "<font size=4><span class='danger'>World Reboot triggered by [key_name(usr)]!</font></span>"
			log_admin("<font size=4><span class='danger'>World Reboot triggered by [key_name(usr)]!</font></span>")
			if(watchdog.waiting)
				watchdog.signal_ready()
			else
				world.Reboot()
		ticker.delay_end = !ticker.delay_end
		log_admin("[key_name(usr)] [ticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		message_admins("\blue [key_name(usr)] [ticker.delay_end ? "delayed the round end" : "has made the round end normally"].", 1)

		return //alert("Round end delayed", null, null, null, null, null)
	if (!( going ))
		going = LOBBY_TICKING_RESTARTED
		ticker.pregame_timeleft = world.timeofday + ticker.remaining_time
		world << "<b>The game will start soon.</b>"
		log_admin("[key_name(usr)] removed the delay.")
	else
		going = LOBBY_TICKING_STOPPED
		world << "<b>The game start has been delayed.</b>"
		log_admin("[key_name(usr)] delayed the game.")
	feedback_add_details("admin_verb","DELAY") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
#undef LOBBY_TICKING_STOPPED
#undef LOBBY_TICKING_RESTARTED
/datum/admins/proc/adjump()
	set category = "Server"
	set desc="Toggle admin jumping"
	set name="Toggle Jump"
	config.allow_admin_jump = !(config.allow_admin_jump)
	message_admins("\blue Toggled admin jumping to [config.allow_admin_jump].")
	feedback_add_details("admin_verb","TJ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adspawn()
	set category = "Server"
	set desc="Toggle admin spawning"
	set name="Toggle Spawn"
	config.allow_admin_spawning = !(config.allow_admin_spawning)
	message_admins("\blue Toggled admin item spawning to [config.allow_admin_spawning].")
	feedback_add_details("admin_verb","TAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adrev()
	set category = "Server"
	set desc="Toggle admin revives"
	set name="Toggle Revive"
	config.allow_admin_rev = !(config.allow_admin_rev)
	message_admins("\blue Toggled reviving to [config.allow_admin_rev].")
	feedback_add_details("admin_verb","TAR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/immreboot()
	set category = "Server"
	set desc="Reboots the server post haste"
	set name="Immediate Reboot"
	if(!usr.client.holder)	return
	if( alert("Reboot server?",,"Yes","No") == "No")
		return
	world << "\red <b>Rebooting world!</b> \blue Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]!"
	log_admin("[key_name(usr)] initiated an immediate reboot.")

	feedback_set_details("end_error","immediate admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]")
	feedback_add_details("admin_verb","IR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(blackbox)
		blackbox.save_all_data_to_sql()

	CallHook("Reboot",list())

	if (watchdog.waiting)
		world << "\blue <B>Server will shut down for an automatic update in a few seconds.</B>"
		watchdog.signal_ready()
		return

	world.Reboot()

/datum/admins/proc/unprison(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Unprison"
	if (M.z == 2)
		if (config.allow_admin_jump)
			M.loc = pick(latejoin)
			message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(M)]", 1)
			log_admin("[key_name(usr)] has unprisoned [key_name(M)]")
		else
			alert("Admin jumping disabled")
	else
		alert("[M.name] is not prisoned.")
	feedback_add_details("admin_verb","UP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/proc/is_special_character(mob/M as mob) // returns 1 for specail characters and 2 for heroes of gamemode
	if(!ticker || !ticker.mode)
		return 0
	if (!istype(M))
		return 0
	if(isrev(M) || isrevhead(M))
		if (ticker.mode.config_tag == "revolution")
			return 2
		return 1
	if(iscult(M))
		if (ticker.mode.config_tag == "cult")
			return 2
		return 1
	if(ismalf(M))
		if (ticker.mode.config_tag == "malfunction")
			return 2
		return 1
	if(isnukeop(M))
		if (ticker.mode.config_tag == "nuclear")
			return 2
		return 1
	if(iswizard(M))
		if (ticker.mode.config_tag == "wizard")
			return 2
		return 1
	if(ischangeling(M))
		if (ticker.mode.config_tag == "changeling")
			return 2
		return 1
	if(isborer(M))
		if (ticker.mode.config_tag == "borer")
			return 2
		return 1
	if(isbadmonkey(M))
		if (ticker.mode.config_tag == "monkey")
			return 2
		return 1
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(R.emagged)
			return 1
	if(M.mind&&M.mind.special_role)//If they have a mind and special role, they are some type of traitor or antagonist.
		return 1

	return 0

/*
/datum/admins/proc/get_sab_desc(var/target)
	switch(target)
		if(1)
			return "Destroy at least 70% of the plasma canisters on the station"
		if(2)
			return "Destroy the AI"
		if(3)
			var/count = 0
			for(var/mob/living/carbon/monkey/Monkey in world)
				if(Monkey.z == 1)
					count++
			return "Kill all [count] of the monkeys on the station"
		if(4)
			return "Cut power to at least 80% of the station"
		else
			return "Error: Invalid sabotage target: [target]"
*/
/datum/admins/proc/spawn_atom(var/object as text)
	set category = "Debug"
	set desc = "(atom path) Spawn an atom"
	set name = "Spawn"

	if(!check_rights(R_SPAWN))	return

	var/list/matches = new()

	for(var/path in typesof(/atom))
		if(findtext("[path]", object))
			matches += path

	if(matches.len==0)
		return

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else
		chosen = input("Select an atom type", "Spawn Atom", matches[1]) as null|anything in matches
		if(!chosen)
			return

	if(ispath(chosen,/turf))
		var/turf/T = get_turf(usr.loc)
		T.ChangeTurf(chosen)
	else
		new chosen(usr.loc)

	log_admin("[key_name(usr)] spawned [chosen] at ([usr.x],[usr.y],[usr.z])")
	feedback_add_details("admin_verb","SA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/show_traitor_panel(var/mob/M in mob_list)
	set category = "Admin"
	set desc = "Edit mobs's memory and role"
	set name = "Show Traitor Panel"

	if(!istype(M))
		usr << "This can only be used on instances of type /mob"
		return
	if(!M.mind)
		usr << "This mob has no mind!"
		return

	M.mind.edit_memory()
	feedback_add_details("admin_verb","STP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/toggletintedweldhelmets()
	set category = "Debug"
	set desc="Reduces view range when wearing welding helmets"
	set name="Toggle tinted welding helmes"
	tinted_weldhelh = !( tinted_weldhelh )
	if (tinted_weldhelh)
		world << "<B>The tinted_weldhelh has been enabled!</B>"
	else
		world << "<B>The tinted_weldhelh has been disabled!</B>"
	log_admin("[key_name(usr)] toggled tinted_weldhelh.")
	message_admins("[key_name_admin(usr)] toggled tinted_weldhelh.", 1)
	feedback_add_details("admin_verb","TTWH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleguests()
	set category = "Server"
	set desc="Guests can't enter"
	set name="Toggle guests"
	guests_allowed = !( guests_allowed )
	if (!( guests_allowed ))
		world << "<B>Guests may no longer enter the game.</B>"
	else
		world << "<B>Guests may now enter the game.</B>"
	log_admin("[key_name(usr)] toggled guests game entering [guests_allowed?"":"dis"]allowed.")
	message_admins("\blue [key_name_admin(usr)] toggled guests game entering [guests_allowed?"":"dis"]allowed.", 1)
	feedback_add_details("admin_verb","TGU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/unjobban_panel()
	set name = "Unjobban Panel"
	set category = "Admin"
	if (src.holder)
		src.holder.unjobbanpanel()
	feedback_add_details("admin_verb","UJBP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/datum/admins/proc/output_ai_laws()
	var/ai_number = 0
	for(var/mob/living/silicon/S in mob_list)
		ai_number++
		if(isAI(S))
			usr << "<b>AI [key_name(S, usr)]'s laws:</b>"
		else if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			usr << "<b>CYBORG [key_name(S, usr)] [R.connected_ai?"(Slaved to: [R.connected_ai])":"(Independant)"]: laws:</b>"
		else if (ispAI(S))
			usr << "<b>pAI [key_name(S, usr)]'s laws:</b>"
		else
			usr << "<b>SOMETHING SILICON [key_name(S, usr)]'s laws:</b>"

		if (S.laws == null)
			usr << "[key_name(S, usr)]'s laws are null?? Contact a coder."
		else
			S.laws.show_laws(usr)
	if(!ai_number)
		usr << "<b>No AIs located</b>" //Just so you know the thing is actually working and not just ignoring you.

/datum/admins/proc/show_skills(var/mob/living/carbon/human/M as mob in world)
	set category = "Admin"
	set name = "Show Skills"

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		usr << "Error: you are not an admin!"
		return

	show_skill_window(usr, M)

	return

/client/proc/update_mob_sprite(mob/living/carbon/human/H as mob)
	set category = "Admin"
	set name = "Update Mob Sprite"
	set desc = "Should fix any mob sprite update errors."

	if (!holder)
		src << "Only administrators may use this command."
		return

	if(istype(H))
		H.regenerate_icons()

//
//
//ALL DONE
//*********************************************************************************************************
//TO-DO:
//
//


/**********************Administration Shuttle**************************/

var/admin_shuttle_location = 0 // 0 = centcom 13, 1 = station

proc/move_admin_shuttle()
	var/area/fromArea
	var/area/toArea
	if (admin_shuttle_location == 1)
		fromArea = locate(/area/shuttle/administration/station)
		toArea = locate(/area/shuttle/administration/centcom)
	else
		fromArea = locate(/area/shuttle/administration/centcom)
		toArea = locate(/area/shuttle/administration/station)
	fromArea.move_contents_to(toArea)
	if (admin_shuttle_location)
		admin_shuttle_location = 0
	else
		admin_shuttle_location = 1
	return

/**********************Centcom Ferry**************************/

var/ferry_location = 0 // 0 = centcom , 1 = station

proc/move_ferry()
	var/area/fromArea
	var/area/toArea
	if (ferry_location == 1)
		fromArea = locate(/area/shuttle/transport1/station)
		toArea = locate(/area/shuttle/transport1/centcom)
	else
		fromArea = locate(/area/shuttle/transport1/centcom)
		toArea = locate(/area/shuttle/transport1/station)
	fromArea.move_contents_to(toArea)
	if (ferry_location)
		ferry_location = 0
	else
		ferry_location = 1
	return

/**********************Alien ship**************************/

var/alien_ship_location = 1 // 0 = base , 1 = mine

proc/move_alien_ship()
	var/area/fromArea
	var/area/toArea
	if (alien_ship_location == 1)
		fromArea = locate(/area/shuttle/alien/mine)
		toArea = locate(/area/shuttle/alien/base)
	else
		fromArea = locate(/area/shuttle/alien/base)
		toArea = locate(/area/shuttle/alien/mine)
	fromArea.move_contents_to(toArea)
	if (alien_ship_location)
		alien_ship_location = 0
	else
		alien_ship_location = 1
	return

proc/formatJumpTo(location, where = "")
	var/turf/loc

	if (isturf(location))
		loc = location
	else
		loc = get_turf(location)

	if (where == "")
		where = formatLocation(loc)

	return "<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>[where]</a>"

proc/formatLocation(location)
	var/turf/loc

	if (isturf(location))
		loc = location
	else
		loc = get_turf(location)

	var/area/A = get_area(location)
	var/answer = "[istype(A) ? "[A.name]" : "UNKNOWN"] - [istype(loc) ? "[loc.x],[loc.y],[loc.z]" : "UNKNOWN"]"
	return answer

proc/formatPlayerPanel(var/mob/U,var/text="PP")
	return "<A HREF='?_src_=holder;adminplayeropts=\ref[U]'>[text]</A>"
