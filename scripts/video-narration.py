import asyncio,edge_tts
async def main():
 c=edge_tts.Communicate("Toda academia tem um ritmo. O aluno que chega cedo. A equipe que acompanha cada conquista. E o trabalho que continua depois do último treino. Mas, entre atendimentos, mensalidades e mensagens, um contato importante pode ficar para depois. A Ritmo nasceu para ajudar a mudar essa rotina. Estamos desenvolvendo uma plataforma para automatizar o relacionamento entre academias e alunos. A proposta é lembrar vencimentos, identificar períodos sem frequência e ajudar a equipe a agir no momento certo. Com regras configuráveis, comunicação autorizada e um painel para acompanhar cada ação. Primeiro, em simulação. Depois, com as integrações e validações necessárias para o uso real. E, para negócios que precisam se apresentar melhor na internet, a Ritmo também cria landing pages com identidade própria, navegação clara e foco em transformar interesse em contato. Tecnologia para simplificar o dia a dia. Design para apresentar o seu valor. Ritmo. Mais tempo para cuidar de quem move o seu negócio. Conheça o projeto e converse com a gente.","pt-BR-AntonioNeural",rate="-3%",pitch="-2Hz",boundary="WordBoundary")
 s=edge_tts.SubMaker()
 with open("/vercel/video/narration.mp3","wb") as f:
  async for chunk in c.stream():
   if chunk["type"]=="audio": f.write(chunk["data"])
   elif chunk["type"]=="WordBoundary": s.feed(chunk)
 with open("/vercel/video/captions.srt","w") as f: f.write(s.get_srt())
 print("Narração masculina e legendas geradas.")
asyncio.run(main())