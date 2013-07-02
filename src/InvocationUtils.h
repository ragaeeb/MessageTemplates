#ifndef INVOCATIONUTILS_H_
#define INVOCATIONUTILS_H_

#include <QObject>
#include <QVariantMap>

namespace canadainc {

class InvocationUtils : public QObject
{
	Q_OBJECT

public:
	InvocationUtils(QObject* parent=NULL);
	Q_INVOKABLE static void replyToMessage(qint64 accountId, QVariantMap const& message, QString body);
};

} /* namespace canadainc */
#endif /* INVOCATIONUTILS_H_ */
