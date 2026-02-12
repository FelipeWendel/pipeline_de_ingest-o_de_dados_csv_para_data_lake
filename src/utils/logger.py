"""
Utilitários para logging estruturado.
"""
import logging
import structlog
from typing import Any


def configurar_logging(nivel_log: str = "INFO"):
    """
    Configura logging estruturado para a aplicação.
    
    Args:
        nivel_log: Nível de log (DEBUG, INFO, WARNING, ERROR, CRITICAL)
    """
    logging.basicConfig(
        format="%(message)s",
        level=getattr(logging, nivel_log.upper()),
    )
    
    structlog.configure(
        processors=[
            structlog.stdlib.filter_by_level,
            structlog.stdlib.add_logger_name,
            structlog.stdlib.add_log_level,
            structlog.stdlib.PositionalArgumentsFormatter(),
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.StackInfoRenderer(),
            structlog.processors.format_exc_info,
            structlog.processors.UnicodeDecoder(),
            structlog.processors.JSONRenderer()
        ],
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
        cache_logger_on_first_use=True,
    )


def obter_logger(nome: str) -> Any:
    """
    Obtém um logger estruturado.
    
    Args:
        nome: Nome do logger
        
    Returns:
        Logger estruturado
    """
    return structlog.get_logger(nome)
