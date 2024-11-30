package br.com.sigas.repositories;

import java.math.BigDecimal;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import br.com.sigas.entities.ItensOperacao;

@Repository
public interface ItensOperacaoRepository extends JpaRepository<ItensOperacao, Long> {

        @Modifying
        @Transactional
        @Query(value = "INSERT INTO itens_operacao (id_operacao, id_produto, quantidade, preco_unitario, valor_total) "
                        +
                        "VALUES (:idOperacao, :idProduto, :quantidade, :precoUnitario, :quantidade * :precoUnitario)", nativeQuery = true)
        void inserirItemOperacao(
                        @Param("idOperacao") Integer idOperacao,
                        @Param("idProduto") Long idProduto,
                        @Param("quantidade") Integer quantidade,
                        @Param("precoUnitario") BigDecimal precoUnitario);

        @Modifying
        @Transactional
        @Query(value = "UPDATE itens_operacao " +
                        "SET quantidade = :quantidade, " +
                        "    preco_unitario = :precoUnitario, " +
                        "    valor_total = :quantidade * :precoUnitario " +
                        "WHERE id_item_operacao = :idItemOperacao", nativeQuery = true)
        void atualizarItemOperacao(
                        @Param("idItemOperacao") Long idItemOperacao,
                        @Param("quantidade") Integer quantidade,
                        @Param("precoUnitario") BigDecimal precoUnitario);

        @Modifying
        @Transactional
        @Query(value = "DELETE FROM itens_operacao WHERE id_item_operacao = :idItemOperacao", nativeQuery = true)
        void deletarItemOperacao(@Param("idItemOperacao") Long idItemOperacao);
}
