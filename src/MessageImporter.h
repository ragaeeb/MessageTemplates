#ifndef MESSAGEIMPORTER_H_
#define MESSAGEIMPORTER_H_

#include <QObject>
#include <QRunnable>
#include <QVariantList>

namespace canadainc {

class MessageImporter : public QObject, public QRunnable
{
	Q_OBJECT

	qint64 m_accountKey;

signals:
	/**
	 * Emitted once all the SMS messages have been imported.
	 * @param qvl A list of QVariantMap objects. Each entry has a key for the conversation ID, and a name of the contact it is
	 * associated with.
	 */
	void importCompleted(QVariantList const& qvl);
	void progress(int current, int total);

public:
	MessageImporter(qint64 accountKey);
	~MessageImporter();
	void run();
};

} /* namespace canadainc */
#endif /* MESSAGEIMPORTER_H_ */
