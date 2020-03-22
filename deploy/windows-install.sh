
if [ $# -lt 7 ]; then
    echo $#
    echo "$0 MYSQL_IP MYSQL_PASSWORD HOSTIP REBUILD(true/false) SLAVE(false[default]/true) MYSQL_USER MYSQL_PORT";
    exit 1
fi

MYSQLIP=$1
PASS=$2
HOSTIP=$3
REBUILD=$4
SLAVE=$5
USER=$6
PORT=$7

if [ "$USER" == "" ]; then
    USER="root"
fi

if [ "$PORT" == "" ]; then
    PORT="3306"
fi

if [ "$REBUILD" != "true" ]; then
  REBUILD="false"
fi

if [ "$SLAVE" != "true" ]; then
    SLAVE="false"
fi

#########################################################################

NODE_VERSION="v12.13.0"

TARS_PATH=c:/tars-install
MIRROR=http://mirrors.cloud.tencent.com

export TARS_INSTALL=$(cd $(dirname $0); pwd)

if [ "${SLAVE}" != "true" ]; then

  if [ ! -d ${TARS_INSTALL}\\web ]; then
      echo "no web exits, please copy TarsWeb to ${TARS_INSTALL}\\web first:"
      echo "cd ${TARS_INSTALL}; git clone https://github.com/TarsCloud/TarsWeb.git web"
      exit 1
  fi

  if [ ! -d ${TARS_INSTALL}\\web\\demo ]; then
      echo "web not the newest version, please update to the newest version."
      exit 1
  fi
fi
  ################################################################################
  #check node version
   
  cd web; npm install;
  cd demo; npm install;

npm config set registry ${MIRROR}/npm/; npm install -g npm pm2

################################################################################

cp -rf ${TARS_INSTALL}/web/sql/*.sql ${TARS_INSTALL}/framework/sql/
cp -rf ${TARS_INSTALL}/web/demo/sql/*.sql ${TARS_INSTALL}/framework/sql/

TARS="tarsAdminRegistry tarslog tarsconfig tarsnode  tarsnotify  tarspatch  tarsproperty  tarsqueryproperty  tarsquerystat  tarsregistry  tarsstat"

cd ${TARS_INSTALL}/framework/servers-win;
for var in $TARS;
do
  echo "tar czf ${var}.tgz ${var}"
  tar czf ${var}.tgz ${var}
done

mkdir -p ${TARS_INSTALL}/web/files/
cp -rf ${TARS_INSTALL}/framework/servers-win/*.tgz ${TARS_INSTALL}/web/files/
rm -rf ${TARS_INSTALL}/framework/servers-win/*.tgz
cp ${TARS_INSTALL}/tools/install.sh ${TARS_INSTALL}/web/files/

################################################################################

cd ${TARS_INSTALL}

./windows-tars-install.sh ${MYSQLIP} ${PASS} ${HOSTIP} ${REBUILD} ${SLAVE} ${USER}  ${PORT} ${TARS_PATH}

