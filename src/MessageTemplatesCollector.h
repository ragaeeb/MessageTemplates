#ifndef MESSAGETEMPLATESCOLLECTOR_H_
#define MESSAGETEMPLATESCOLLECTOR_H_

#include "AppLogFetcher.h"

#define CARD_LOG_FILE QString("%1/logs/card.log").arg( QDir::currentPath() )

namespace messagetemplates {

using namespace canadainc;

class MessageTemplatesCollector : public LogCollector
{
public:
    MessageTemplatesCollector();
    QByteArray compressFiles();
    ~MessageTemplatesCollector();
};

} /* namespace messagetemplates */

#endif /* MESSAGETEMPLATESCOLLECTOR_H_ */
