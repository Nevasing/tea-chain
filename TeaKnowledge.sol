// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TeaKnowledge
 * @dev Децентрализованный архив чайных знаний
 * 
 * ВАЖНО: Этот проект закрыт в 2025 году после осознанного анализа.
 * ПОЧЕМУ? Блокчейн не решает проблему физического чая, но идеален для архива знаний.
 * 
 * Урок: Блокчейн уместен ТОЛЬКО там, где данные уже цифровые (оценки, ноты, советы).
 * Для физических объектов он создаёт больше проблем, чем решает.
 */
contract TeaKnowledge {
    struct QUD {
        uint8 quality;      // 0-20 (вкус + аромат + чи + проливы)
        uint8 uniqueness;   // 0-20 (регион + обработка + партия + история)
        uint8 demand;       // 0-15 (цена + доступность + подделки)
        bool isExpert;
    }

    // Храним оценки по хешу описания чая
    mapping(bytes32 => QUD[]) public knowledgeBase;

    event KnowledgeAdded(
        bytes32 indexed teaHash,
        uint8 quality,
        uint8 uniqueness,
        uint8 demand,
        bool isExpert,
        uint256 normalizedScore
    );

    /**
     * @notice Добавить знание в архив
     * @dev Проверяет диапазоны оценок и рассчитывает нормализованный балл
     * @param teaDescription Описание чая (например, "Shou Puer 2010 Ban Zhang")
     * @param quality Оценка качества (0-20)
     * @param uniqueness Оценка уникальности (0-20)
     * @param demand Оценка доступности (0-15)
     */
    function addKnowledge(
        string memory teaDescription,
        uint8 quality,
        uint8 uniqueness,
        uint8 demand
    ) external {
        // Проверяем диапазоны (0-20/0-20/0-15)
        require(quality <= 20, "Quality >20");
        require(uniqueness <= 20, "Uniqueness >20");
        require(demand <= 15, "Demand >15");

        bytes32 teaHash = keccak256(abi.encodePacked(teaDescription));
        
        knowledgeBase[teaHash].push(QUD({
            quality: quality,
            uniqueness: uniqueness,
            demand: demand,
            isExpert: _isExpert(msg.sender)
        }));

        uint256 score = _calculateNormalizedScore(teaHash);
        emit KnowledgeAdded(
            teaHash, 
            quality, 
            uniqueness, 
            demand, 
            _isExpert(msg.sender), 
            score
        );
    }

    /**
     * @notice Получить нормализованный балл (0-100)
     * @param teaHash Хеш описания чая
     * @return Нормализованный балл
     */
    function getScore(bytes32 teaHash) external view returns (uint256) {
        return _calculateNormalizedScore(teaHash);
    }

    /**
     * @dev Проверка статуса эксперта
     * В реальном проекте здесь была бы интеграция с TeaExpert.sol
     */
    function _isExpert(address _addr) internal view returns (bool) {
        // В закрытом проекте эксперты не верифицируются
        return false;
    }

    /**
     * @dev Расчёт нормализованного балла
     * Формула: (сырой балл × 100) / 115
     */
    function _calculateNormalizedScore(bytes32 teaHash) internal view returns (uint256) {
        QUD[] memory teaVotes = knowledgeBase[teaHash];
        if (teaVotes.length == 0) return 0;

        uint256 totalRawScore;
        uint256 totalWeight;

        for (uint256 i = 0; i < teaVotes.length; i++) {
            QUD memory v = teaVotes[i];
            uint256 weight = v.isExpert ? 2 : 1;
            uint256 rawScore = 
                (v.quality * 3) + 
                (v.uniqueness * 2) + 
                (v.demand * 1);

            totalRawScore += rawScore * weight;
            totalWeight += weight;
        }

        return (totalRawScore * 100) / (115 * totalWeight);
    }
}
