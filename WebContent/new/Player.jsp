<%@page import="game.global.Constant"%>
<%@page import="game.global.Player"%>
<%@page import="game.global.Game"%>
<%@page import="game.global.GamesStorage"%>
<%@page import="java.util.Map"%>
<%@page import="org.apache.tomcat.util.codec.binary.Base64"%>
<%@page import="java.util.Iterator"%>
<%@page import="game.global.Storage"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%!%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<%
	String game_uniqueID = null;
	String player_uniqueID = null; 

	Cookie cookie = null;
	Cookie[] cookies = null;
	cookies = request.getCookies();
	if (cookies != null) {
		for (int i = 0; i < cookies.length; i++) {
			cookie = cookies[i];
			if (cookie.getName().equalsIgnoreCase("player_uniqueID")) {
				//player_uniqueID = new String(Base64.decodeBase64(cookie.getValue()));
				player_uniqueID = cookie.getValue();
			} else if (cookie.getName().equalsIgnoreCase("game_uniqueID")) {
				game_uniqueID = cookie.getValue();
			}
		}
	}
	Game game=GamesStorage.getGame(game_uniqueID);
	Player player=null;
	if(game!=null)
		player=GamesStorage.getGame(game_uniqueID).getPlayer(player_uniqueID);
	if (game!=null && player!=null ) 
	{	
%>

<title><%=player.getName() +"  - " + game.getName()%></title>
	<%} %>
<jsp:include page="clientJSFunctions.jsp">
		<jsp:param name="game_uniqueID" value="<%=game_uniqueID%>" />
		<jsp:param name="player_uniqueID" value="<%=player_uniqueID%>" />
		<jsp:param name="auto_refersh_page" value="Player.jsp" />
		<jsp:param name="auto_refersh_div" value="#players_div" />
</jsp:include>
	
</head>
<body>
	<%
	if (!GamesStorage.isGameExist(game_uniqueID)) 
	{
		%>sorry game expired on server<%
		Cookie to_delete = new Cookie("game_uniqueID", "");
		to_delete.setMaxAge(0);
		response.addCookie(to_delete);
		to_delete = new Cookie("player_uniqueID", "");
		to_delete.setMaxAge(0);
		response.addCookie(to_delete);
	}
	else
	{%>
	<div id="status_div">
		<%=game.getName() + "("+game.uniqueID+")"%>
	</div>
	
	<div id="players_div">
		<%=System.currentTimeMillis()%>
		<%
			Map<String, Player> players = game.getPlayers();
		
			switch(game.getState())
			{
			case Game.waiting: 
			case Game.START_STATE:
				%>
				waiting for superviser to start game......
				<%
				break;
			case Game.assign_roles:
				%>
				roles are assigned.... You are <%=Constant.GAME_ROLES[player.getRole()]%>
				<%
				break;
			case Game.city_sleeps_mafia_kill_someone_detective_identify_someone_and_doctor_save_someone:
				%>
				You are <%=Constant.GAME_ROLES[player.getRole()]%>
				<br>
				<%=Constant.GAME_STATES[game.getState()] %>
				<%
				break;
			case Game.city_wake_up_and_elimimate_someone:
				%>
				You are <%=Constant.GAME_ROLES[player.getRole()]%>
				<br>
				<%=Constant.GAME_STATES[game.getState()] %>
				<%
				break;
			}
		
			if (!GamesStorage.isGameExist(game.uniqueID)) {
				%>sorry game expired on server<%
			} else 
			{
				%><table border="1">
				<tr>
					<th>Player</th>
					<th>Role</th>
					<th>Votes</th>
					<th>Voted to</th>
	
				</tr><%
				
				switch(game.getState())
				{
				case Game.city_sleeps_mafia_kill_someone_detective_identify_someone_and_doctor_save_someone:
					for (Map.Entry<String, Player> i_Player : players.entrySet()) 
					{ 
						%>
						<tr <%=i_Player.getValue().isKilled()?"style=\"background-color:#AA5555\"":""%> >
							<%

							if(player.getRole()==Player.Mafia && !i_Player.getValue().isKilled())
							{
								if( player.getWhoIKilled() != i_Player.getValue() && i_Player.getValue().getRole() != Player.Mafia)
								{
									%>
									<td><button onclick="callMethodAndRefresh('Player.jsp','#players_div','killPlayer','<%=i_Player.getValue().uniqueID%>');">kill '<%=i_Player.getValue().getName()%>'</button></td> 
									<td><%=i_Player.getValue().getRole()==player.getRole() && player.getRole()!=Player.Civilian?Constant.GAME_ROLES[i_Player.getValue().getRole()]:""%></td>
									<td><%=i_Player.getValue().getKillVote()%></td>
									<td></td>
									<%
								} else if(i_Player.getValue().getWhoIKilled()!=null) 
								{
									%>
									<td><%=i_Player.getValue().getName()%></td>  
									<td><%=i_Player.getValue().getRole()==player.getRole() && player.getRole()!=Player.Civilian?Constant.GAME_ROLES[i_Player.getValue().getRole()]:""%></td>
									<td><%=i_Player.getValue().getKillVote()%></td>
									<td><%=i_Player.getValue().getWhoIKilled().getName()%></td>
									<%
								} else
								{
									%>
									<td><%=i_Player.getValue().getName()%></td>  
									<td><%=i_Player.getValue().getRole()==player.getRole() && player.getRole()!=Player.Civilian?Constant.GAME_ROLES[i_Player.getValue().getRole()]:""%></td>
									<td><%=i_Player.getValue().getKillVote()%></td>
									<td></td>
									<%
								}
										
							} else if(player.getRole()==Player.Detective && !i_Player.getValue().isKilled())
							{
								if( player.getWhoIIdentified() != i_Player.getValue() && i_Player.getValue().getRole() != Player.Detective)
								{
									%>
									<td><button onclick="callMethodAndRefresh('Player.jsp','#players_div','identifyPlayer','<%=i_Player.getValue().uniqueID%>');">identify '<%=i_Player.getValue().getName()%>'</button></td> 
									<td><%=i_Player.getValue().getRole()==player.getRole() && player.getRole()!=Player.Civilian?Constant.GAME_ROLES[i_Player.getValue().getRole()]:""%></td>
									<td><%=i_Player.getValue().getIdentifyVote()%></td>
									<td></td>
									<%
								} else if(i_Player.getValue().getWhoIIdentified()!=null) 
								{ 
									%>
									<td><%=i_Player.getValue().getName()%></td>  
									<td><%=i_Player.getValue().getRole()==player.getRole() && player.getRole()!=Player.Civilian?Constant.GAME_ROLES[i_Player.getValue().getRole()]:""%></td>
									<td><%=i_Player.getValue().getIdentifyVote()%></td>
									<td><%=i_Player.getValue().getWhoIIdentified().getName()%></td>
									<%
								} else
								{
									%>
									<td><%=i_Player.getValue().getName()%></td>  
									<td><%=i_Player.getValue().getRole()==player.getRole() && player.getRole()!=Player.Civilian?Constant.GAME_ROLES[i_Player.getValue().getRole()]:""%></td>
									<td><%=i_Player.getValue().getIdentifyVote()%></td>
									<td></td>
									<%
								}
										
							} else if(player.getRole()==Player.Doctor && !i_Player.getValue().isKilled())
							{
								if( player.getWhoISaved() != i_Player.getValue() && i_Player.getValue().getRole() != Player.Doctor)
								{
									%>
									<td><button onclick="callMethodAndRefresh('Player.jsp','#players_div','savePlayer','<%=i_Player.getValue().uniqueID%>');">kill '<%=i_Player.getValue().getName()%>'</button></td> 
									<td><%=i_Player.getValue().getRole()==player.getRole() && player.getRole()!=Player.Civilian?Constant.GAME_ROLES[i_Player.getValue().getRole()]:""%></td>
									<td><%=i_Player.getValue().getSaveVote()%></td>
									<td></td>
									<%
								} else if(i_Player.getValue().getWhoISaved()!=null) 
								{
									%>
									<td><%=i_Player.getValue().getName()%></td>  
									<td><%=i_Player.getValue().getRole()==player.getRole() && player.getRole()!=Player.Civilian?Constant.GAME_ROLES[i_Player.getValue().getRole()]:""%></td>
									<td><%=i_Player.getValue().getSaveVote()%></td>
									<td><%=i_Player.getValue().getWhoISaved().getName()%></td>
									<%
								} else
								{
									%>
									<td><%=i_Player.getValue().getName()%></td>  
									<td><%=i_Player.getValue().getRole()==player.getRole() && player.getRole()!=Player.Civilian?Constant.GAME_ROLES[i_Player.getValue().getRole()]:""%></td>
									<td><%=i_Player.getValue().getSaveVote()%></td>
									<td></td>
									<%
								}
										
							} else
							{
								%>
								<td><%=i_Player.getValue().getName()%></td>  
								<td><%=i_Player.getValue().getRole()==player.getRole() && player.getRole()!=Player.Civilian?Constant.GAME_ROLES[i_Player.getValue().getRole()]:""%></td>
								<td></td>
								<td></td>
								<%
							}
							%>
						</tr>
						<%
					}
					break;
				case Game.city_wake_up_and_elimimate_someone:

					for (Map.Entry<String, Player> i_Player : players.entrySet()) 
					{
						%>
						<tr <%=i_Player.getValue().isKilled()?"style=\"background-color:#AA5555\"":""%> >
						<%
							if(i_Player.getValue().isKilled())
							{
								%>
								<td><%=i_Player.getValue().getName()%></td> 
								<td><%=Constant.GAME_ROLES[i_Player.getValue().getRole()]%></td>
								<td></td>
								<td></td>
								<%		
							}else 
							{
								//if(!player.isKilled()  && i_Player.getValue().getWhoIEliminate()!=null)
								if(player==i_Player.getValue()) 
								{
									%>
									<td><%=i_Player.getValue().getName()%></button></td>  
									<td><%=i_Player.getValue().getRole()==player.getRole() && player.getRole()!=Player.Civilian?Constant.GAME_ROLES[i_Player.getValue().getRole()]:""%></td>
									<td><%=i_Player.getValue().getEliminateVote()%></td>
									<% 
									if(i_Player.getValue().getWhoIEliminate()==null)
									{
										%><td></td><% 
									}else
									{
										%><td><%=i_Player.getValue().getWhoIEliminate().getName()%></td><% 
									}
								}else if (!player.isKilled())
								{
									%>
									<td><button onclick="callMethodAndRefresh('Player.jsp','#players_div','eliminatePlayer','<%=i_Player.getValue().uniqueID%>');">eliminate '<%=i_Player.getValue().getName()%>'</button></td>   
									<td><%=i_Player.getValue().getRole()==player.getRole() && player.getRole()!=Player.Civilian?Constant.GAME_ROLES[i_Player.getValue().getRole()]:""%></td>
									<td><%=i_Player.getValue().getEliminateVote()%></td> 
									<%
									if(i_Player.getValue().getWhoIEliminate()==null)
									{
										%><td></td><% 
									}else
									{
										%><td><%=i_Player.getValue().getWhoIEliminate().getName()%></td><% 
									}
								}else 
								{
									%>
									<td><%=i_Player.getValue().getName()%></button></td>   
									<td><%=i_Player.getValue().getRole()==player.getRole() && player.getRole()!=Player.Civilian?Constant.GAME_ROLES[i_Player.getValue().getRole()]:""%></td>
									<td><%=i_Player.getValue().getEliminateVote()%></td>
									<td></td>
									<%
								}
							}
						
						%>
						</tr>
						<%
					}
					break;
				default:
					for (Map.Entry<String, Player> i_Player : players.entrySet()) 
					{
						%>
						<tr  <%=i_Player.getValue().isKilled()?"style=\"background-color:#AA5555\"":""%> >
							<td><%=i_Player.getValue().getName()%></td> 
							<td><%=i_Player.getValue().getRole()==player.getRole() && player.getRole()!=Player.Civilian ?Constant.GAME_ROLES[i_Player.getValue().getRole()]:""%></td>
							<td></td>
							<td></td>
						</tr>
						<%
					}
					break;
				}
				%></table><%
			}
		%>
	</div>
	
	<%
	}
	%>
</body>
</html>