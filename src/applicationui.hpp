#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "LazySceneCover.h"
#include "LocaleUtil.h"
#include "Persistance.h"

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

	LocaleUtil m_locale;
    Persistance m_persistance;
	LazySceneCover m_cover;

    ApplicationUI(bb::cascades::Application* app);

private slots:
	void init();

signals:
	void accountsImported(QVariantList const& qvl);
	void messagesImported(QVariantList const& qvl);
	void loadProgress(int current, int total);
	void initialize();

public:
	static void create(bb::cascades::Application* app);
    virtual ~ApplicationUI();

    Q_INVOKABLE void loadAccounts();
    Q_INVOKABLE void loadMessages(qint64 accountId);
};

} // salat

#endif /* ApplicationUI_HPP_ */
