-- 1.Grass 타입의 포켓몬을 사전순으로 출력
select name
from Pokemon
where Pokemon.type = "Grass"
order by name;

-- 2.Brown City 또는 Rainbow City 출신 트레이너의 이름을 사전순으로 출력하세요
select name
from Trainer
where Trainer.hometown = "Brown City" || Trainer.hometown = "Rainbow City"
order by name;

-- 3.모든 포켓몬의 type을 중복없이 사전순으로 출력하세요
select distinct type
from Pokemon
order by type;

-- 4.도시의 이름이 B로 시작하는 모든 도시의 이름을 사전순으로 출력하세요
select name
from City
where City.name like "B%"
order by name;

-- 5.이름이 M으로 시작하지 않는 트레이너의 고향을 사전순으로 출력하세요
select hometown
from Trainer
where Trainer.name not in (
select name
from Trainer 
where Trainer.name like "M%")
order by hometown;

-- 6.잡힌 포켓몬 중 가장 레벨이 높은 포켓몬의 별명을 사전순으로 출력하세요
select nickname
from CatchedPokemon
where CatchedPokemon.level in (
select Max(level)
from CatchedPokemon
)
order by nickname;


-- 7.포켓몬의 이름이 알파벳 모음으로 시작하는 포켓몬의 이름을 사전순으로 출력하세요
select name
from Pokemon
where (name LIKE 'I%' OR name LIKE 'E%' OR name LIKE 'A%'OR name LIKE 'O%'OR name LIKE 'U%')
order by name;

-- 8.잡힌 포켓몬의 평균 레벨을 출력하세요
select avg(level)
from CatchedPokemon;

-- 9. Yellow가 잡은 포켓몬의 최대 레벨을 출력하세요
select max(level)
from CatchedPokemon
where CatchedPokemon.owner_id in (
select id
from Trainer
where name ="Yellow"
);

-- 10.트레이너의 고향 이름을 중복없이 사전순으로 출력하세요
select distinct hometown
from Trainer
order by hometown;

-- 11.닉네임이 A로 시작하는 포켓몬을 잡은 트레이너의 이름과 포켓몬의 닉네임을 트레이너의 이름의 사전순으로 출력하세요
select name, nickname
from CatchedPokemon as C, Trainer as T
where C.nickname like "A%" and C.owner_id = T.id
order by T.name;


-- 12. Amazon 특성을 가진 도시의 리더의 트레이너 이름을 출력하세요
select name
from Trainer
where Trainer.id in (
select leader_id
from Gym
where city in (
select name
from City 
where description = "Amazon"
)
);

-- 13. 불속성 포켓몬을 가장 많이 잡은 트레이너의 id와, 그 트레이너가 잡은 불속성 포켓몬의 수를 출력하세
select owner_id, count(*) as fireCount
from CatchedPokemon left join Pokemon on CatchedPokemon.pid = Pokemon.id
where type = "Fire"
group by owner_id
order by fireCount desc
limit 1;

-- 14. 포켓몬 ID가 한 자리 수인 포켓몬의 type을 중복 없이 포켓몬 ID의 내림차순으로 출력하세요
select type
from Pokemon
where id < 10
group by type
order by min(id) desc;

-- 15. 포켓몬의 type이 Fire이 아닌 포켓몬의 수를 출력하세요
select count(*)
from Pokemon
where type != "Fire";


-- 16. 진화하면id가작아지는포켓몬의진화전이름을사전순으로출력하세요
select name
from Evolution join Pokemon on Evolution.before_id = Pokemon.id
where before_id > after_id
order by name;

-- 17. 트레이너에게 잡힌 모든 물속성 포켓몬의 평균 레벨을 출력하세요
select avg(level)
from CatchedPokemon join Pokemon on CatchedPokemon.pid = Pokemon.id
where type = "Water";

-- 18. 체육관 리더가 잡은 모든 포켓몬 중 레벨이 가장 높은 포켓몬의 별명을 출력하세요
select nickname
from CatchedPokemon join Gym on CatchedPokemon.owner_id = Gym.leader_id
where level = (select max(level)
from CatchedPokemon join Gym on CatchedPokemon.owner_id = Gym.leader_id);

-- 19. Blue city 출신 트레이너들 중 잡은 포켓몬들의 레벨의 평균이 가장 높은 트레이너의 이름을 사전순으로 출력하세요
with avgTable as (
select name, avg(level) as levelAvg
from CatchedPokemon join Trainer on CatchedPokemon.owner_id = Trainer.id
where hometown = "Blue City"
group by name
)
select name
from avgTable
where avgTable.levelAvg = (
select max(levelAvg)
from avgTable
)
order by name;

-- 20. 같은 출신이 없는 트레이너들이 잡은 포켓몬중 진화가 가능하고 Electric 속성을 가진 포켓몬의 이름을 출력하세요
with tempTable as (
select pokeName, hometown
from (
select name as pokeName, pid, owner_id, type
from CatchedPokemon join Pokemon on CatchedPokemon.pid = Pokemon.id
where type = "Electric" and (pid in (
select before_id
from Evolution) )
) as temp join Trainer on owner_id = Trainer.id
)
select pokeName
from tempTable
where hometown in (
select hometown
from Trainer 
group by hometown 
having count(*) < 2
)
group by pokeName;

-- 21. 관장들의 이름과 각 관장들이 잡은 포켓몬들의 레벨 합을 레벨 합의 내림차 순으로 출력하세요
select name, sum(level)
from CatchedPokemon join Gym on CatchedPokemon.owner_id = Gym.leader_id join Trainer on Trainer.id = owner_id
group by owner_id
order by sum(level) desc;

-- 22. 가장 트레이너가 많은 고향의 이름을 출력하세요.
with countTable as (
select count(*) as hometownCount, hometown
from Trainer
group by hometown
)
select hometown
from countTable
where hometownCount = (select max(hometownCount) from countTable);

-- 23. Sangnok City 출신 트레이너와 Brown City 출신 트레이너가 공통으로 잡은 포켓몬의 이름을 중복을 제거하여 사전순으로 출력
select name
from (
select distinct Pokemon.name
from CatchedPokemon join Trainer on owner_id = Trainer.id and Trainer.hometown = "Sangnok City" join Pokemon on CatchedPokemon.pid = Pokemon.id
) a
where a.name in (
select distinct Pokemon.name
from CatchedPokemon join Trainer on owner_id = Trainer.id and Trainer.hometown = "Brown City" join Pokemon on CatchedPokemon.pid = Pokemon.id
)
order by name;

-- 24. 이름이 P로 시작하는 포켓몬을 잡은 트레이너 중 상록 시티 출신인 트레이너의 이름을 사전순으로 모두 출력하세요
select name 
from Trainer
where hometown = "Sangnok City" and id in (
select owner_id
from CatchedPokemon join Pokemon on CatchedPokemon.pid = Pokemon.id 
where name like "P%"
)
order by name;

-- 25. 트레이너의 이름과 그 트레이너가 잡은 포켓몬의 이름을 출력하세요. 이때 트레이너 이름은 사전 순으로 정렬하고, 각 트레이너가 잡은 포켓몬도 사전 순으로 정렬하세요.
with tempTable as (
select name as pokeName, owner_id
from CatchedPokemon join Pokemon on CatchedPokemon.pid = Pokemon.id
)
select Trainer.name, pokeName
from tempTable join Trainer on owner_id = id
order by name, pokeName;

-- 26. 2단계 진화만 가능한 포켓몬의 이름을 사전순으로 출력하세요 ... 2단 진화라는게 1->2 만 인건가 아님 1->2->3 인건가
select name
from Pokemon join (select before_id
from Evolution
where before_id not in 
(
select ev1.before_id
from Evolution as ev1 join Evolution as ev2 on ev1.after_id = ev2.before_id
) and before_id not in 
(
select ev1.after_id
from Evolution as ev1 join Evolution as ev2 on ev1.after_id = ev2.before_id
)) as A on Pokemon.id = A.before_id
order by name;

-- 27. 상록 시티의 관장이 잡은 포켓몬들 중 포켓몬의 타입이 WATER 인 포켓몬의 별명을 사전순으로 출력 하세요
select nickname
from CatchedPokemon join Gym on owner_id = leader_id and city = "Sangnok City" join Pokemon on pid = Pokemon .id and type = "Water"
order by nickname;

-- 28. 트레이너들이 잡은 포켓몬 중 진화한 포켓몬이 3마리 이상인 경우 해당 트레이너의 이름을 사전순으로 출력하세요
select name
from (
select owner_id 
from CatchedPokemon join Evolution on pid = after_id 
group by owner_id 
having count(*)>2 ) a join Trainer on owner_id = id
order by name; 

-- 29. 어느 트레이너에게도 잡히지 않은 포켓몬의 이름을 사전 순으로 출력하세요
select name
from Pokemon
where id not in (
select pid
from CatchedPokemon
)
order by name;

-- 30. 각 출신 도시별로 트레이너가 잡은 포켓몬중 가장 레벨이 높은 포켓몬의 레벨을 내림차순으로 출력 하세요.
select max(level)
from CatchedPokemon join Trainer on owner_id = Trainer.id
group by hometown
order by max(level) desc;

-- 31. 포켓몬 중 3단 진화가 가능한 포켓몬의 ID 와 해당 포켓몬의이름을 1단진화 형태 포켓몬의이름, 2단진화 형태 포켓몬의 이름, 3단 진화 형태 포켓몬의 이름을 ID 의 오름차순으로 출력하세요
with genId as (
select ev1.before_id as gen1, ev1.after_id as gen2, ev2.after_id as gen3
from Evolution as ev1 join Evolution as ev2 on ev1.after_id = ev2.before_id)
select gen1Name.gen1 as id, gen1Name.name as firstName, gen2Name.name as secondName, gen3Name.name as thirdName
from 
(select name, gen1 from Pokemon join genId on Pokemon.id = genId.gen1) as gen1Name, 
(select name, gen2 from Pokemon join genId on Pokemon.id = genId.gen2) as gen2Name, 
(select name, gen3 from Pokemon join genId on Pokemon.id = genId.gen3) as gen3Name
where (gen1Name.gen1 , gen2Name.gen2, gen3Name.gen3) in (select * from genId)
order by id
