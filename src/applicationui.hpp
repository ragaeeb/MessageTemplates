#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "LazySceneCover.h"
#include "LocaleUtil.h"
#include "Persistance.h"

#include <bb/system/InvokeManager>

namespace bb {
	namespace cascades {
		class Application;
	}
}

namespace canadainc {
    class MessageImporter;
}

namespace messagetemplates {

using namespace canadainc;

class ApplicationUI : public QObject
{
	Q_OBJECT

	bb::system::InvokeManager m_invokeManager;
	MessageImporter* m_importer;
	LocaleUtil m_locale;
    Persistance m_persistance;
	LazySceneCover m_cover;
	bb::system::InvokeRequest m_request;
	QObject* m_root;

    ApplicationUI(bb::cascades::Application* app);
    void initRoot(QString const& qml);

private slots:
	void lazyInit();
	void invoked(bb::system::InvokeRequest const& request);
	void onMessagesImported(QVariantList const& qvl);
    void onRestored();
    void onSaved();
	void terminateThreads();

signals:
	void accountsImported(QVariantList const& qvl);
    void backupComplete(QString const& result);
	void initialize();
	void lazyInitComplete();
    void loadProgress(int current, int total);
    void messagesImported(QVariantList const& qvl);
    void restoreComplete(bool result);

public:
	static void create(bb::cascades::Application* app);
    virtual ~ApplicationUI();

    Q_INVOKABLE void backup(QString const& destination);
    Q_SLOT void loadAccounts();
    Q_INVOKABLE void loadMessages(qint64 accountId);
    Q_SLOT void childCardDone(bb::system::CardDoneMessage const& message=bb::system::CardDoneMessage());
    Q_INVOKABLE void processReply(qint64 accountId, QVariantMap const& message, QVariantList const& templateBodies);
    Q_INVOKABLE void restore(QString const& source);
};

} // salat

#endif /* ApplicationUI_HPP_ */
