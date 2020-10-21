# SEMPRE, SEMPRE utilize imagens tagueadas com uma tagueadas especifica. Assim sempre vamos
# ter garantia que essa imagem foi buildada EXATAMENTE com a versão especificada.
# O perigo de fazer um 'golang:alpine' é que a tag 'alpine' sempre aponta para latest (ultima)
# versão lançada do golang:alpine, que hoje pode ser a versão X, amanhã a Y e daqui 1 ano Z.
# Logo o que funciona hoje pode não funcionar daqui um tempo.
# Nesse caso o certo seria descobrir a versão na qual o app foi desenvolvido e especificar na tag:
#
# Exemplo: FROM golang:1.13-alpine3.11 (assim estamos garantindo golang1.13 e alpine 3.11
# Material de apoio: https://vsupalov.com/docker-latest-tag/
FROM golang:alpine

LABEL version="0.0.1"

WORKDIR /go/src/github.com/m-goncalves/webservice

# Antes de copiarmos todo o código fonte é uma boa prática copiar os arquivos do gerenciador de pacotes
# da linguagem que no caso aqui é o "Go Mod" (go.mod e go.sum), se fosse NodeJS seria o package.json e package-lock.json
# O motivo? Otimização no tempo de build. Quando o fonte muda não tem necessidade de baixar todos os módulos a menos
# que algum módulo tenha sido adicionado ou removido do arquivo do gerenciador de pacotes.

COPY go.mod .
COPY go.sum .

# Baixa as dependências do projeto que estão especificadas no Go Mod
RUN go mod download

# Agora podemos fazer copiar o restante do código fonte
COPY . .

# Material de apoio: https://buddy.works/guides/how-speed-up-docker-build

# É uma boa prática colocar a instalação de pacotes sempre no inicio do Dockerfile
# pra otimizar tempo de build. Assim evitamos que esse `RUN` rode a cada vez que o código
# fonte muda. Tenha em mente: Cada instrução do Dockerfile é cacheada e o cache é apagado
# sempre que uma instrução anterior mudar. Exemplo:
#
# COPY readme.txt .
# RUN apt-get install nginx
#
# Nesse caso sempre que o conteúdo do arquivo 'readme.txt' mudar o RUN com o apt-get vai rodar,
# o certo então é mudar a ordem, acelerando o processo de build posteriores.

# Aqui o go get github.com/streadway/amqp é redundate já que ele já foi baixado pelo Go modules 
RUN apk add git \
    && go get github.com/streadway/amqp \
    && GOBIN=/go/bin go install cmd/webservice/webservice.go

ENTRYPOINT /go/bin/webservice

EXPOSE 8080 5672

VOLUME ["/source-images"]


