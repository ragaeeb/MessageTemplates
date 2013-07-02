#include "InvocationUtils.h"
#include "Logger.h"

#include <bb/system/InvokeManager>
#include <bb/PpsObject>

namespace canadainc {

using namespace bb::system;

InvocationUtils::InvocationUtils(QObject* parent) : QObject(parent)
{
}


void InvocationUtils::replyToMessage(qint64 accountId, QVariantMap const& message, QString body)
{
	LOGGER(accountId << message);

	body += "\n\n-------------------\n\n"+message.value("text").toString();
	QByteArray qba = QUrl::toPercentEncoding(body);
	body = QString::fromUtf8( qba.data() );

	QString uri = QString("mailto:%1?subject=%2&body=%3").arg( message.value("senderAddress").toString() ).arg( message.value("subject").toString() ).arg(body);
	LOGGER("URI" << uri);

	bb::system::InvokeManager invokeManager;

	bb::system::InvokeRequest request;
	request.setTarget("sys.pim.uib.email.hybridcomposer");
	request.setAction("bb.action.SENDEMAIL");
	request.setMimeType("message/rfc822");
	request.setUri(uri);

	invokeManager.invoke(request);
}

} /* namespace canadainc */
