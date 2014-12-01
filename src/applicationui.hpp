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

namespace messagetemplates {

using namespace canadainc;

class ApplicationUI : public QObject
{
	Q_OBJECT

	bb::system::InvokeManager m_invokeManager;
	LocaleUtil m_locale;
    Persistance m_persistance;
	LazySceneCover m_cover;
	bb::system::InvokeRequest m_request;
	QObject* m_root;

    ApplicationUI(bb::cascades::Application* app);
    QObject* initRoot(QString const& qml);

private slots:
	void lazyInit();
	void invoked(bb::system::InvokeRequest const& request);

signals:
	void accountsImported(QVariantList const& qvl);
	void messagesImported(QVariantList const& qvl);
	void loadProgress(int current, int total);
	void initialize();

public:
	static void create(bb::cascades::Application* app);
    virtual ~ApplicationUI();

    Q_SLOT void loadAccounts();
    Q_INVOKABLE void loadMessages(qint64 accountId);
    Q_SLOT void childCardDone(bb::system::CardDoneMessage const& message=bb::system::CardDoneMessage());
    Q_INVOKABLE void processReply(qint64 accountId, QVariantMap const& message, QString const& templateBody);
};

} // salat

#endif /* ApplicationUI_HPP_ */
